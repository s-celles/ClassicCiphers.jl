using ClassicCiphers: AbstractCipher, AbstractStreamCipherConfiguration
using ClassicCiphers.Traits: NOT_CASE_SENSITIVE

using OnlineStatsBase
using OnlineStatsBase: OnlineStat, Series


"""
    abstract type AbstractCipherState end

Base abstract type for representing the internal state of a cipher.
This type serves as the parent type for all concrete cipher state implementations.

All subtypes should maintain the necessary state information required for
encryption and decryption operations in stream ciphers.

# Extended help
## Implementation
When implementing a new cipher state type:
- Create a concrete type that inherits from `AbstractCipherState`
- Define necessary fields to store the cipher's internal state
- Implement required methods for state manipulation
"""
abstract type AbstractCipherState end

"""
    EmptyCipherState <: AbstractCipherState

A concrete implementation of `AbstractCipherState` representing an empty cipher state.

This struct is used as a null object pattern for cipher states when no state information 
needs to be maintained during encryption/decryption operations.
"""
struct EmptyCipherState <: AbstractCipherState end

"""
    State(cipher::AbstractStreamCipherConfiguration)

Create an initial empty cipher state for a given stream cipher configuration.

# Arguments
- `cipher::AbstractStreamCipherConfiguration`: The configuration of the stream cipher

# Returns
- `EmptyCipherState`: An empty cipher state instance

This function serves as a default implementation for stream ciphers that don't require
state initialization. For ciphers that need specific state initialization, this method
should be overridden.
"""
State(cipher::AbstractStreamCipherConfiguration) = EmptyCipherState()


"""
A mutable struct representing character count tracking for stream ciphers.

Implements the `AbstractCipherState` interface to maintain state information
about valid characters encountered during encryption/decryption operations.
"""
mutable struct ValidCharCount <: AbstractCipherState
    valid_char_count::Int

    ValidCharCount() = new(0)
end

# Base functionality for character transformation


function process_char!(
    state::AbstractCipherState,
    cipher::AbstractStreamCipherConfiguration{ENC},
    input_char::Char,
) where {ENC}
    fixed_input_char = input_char

    alphabet = cipher.alphabet_params.alphabet

    if !iscasesensitive(cipher.alphabet_params.case_sensitivity)
        fixed_input_char = uppercase(input_char)
    end

    if fixed_input_char in alphabet
        # Find corresponding character position
        index = findfirst(==(fixed_input_char), alphabet)
        transformed_index = transform_index(cipher, index)
        base_char = alphabet[transformed_index]

        # Get case trait and apply output case rules
        trait = output_case_handling_trait(cipher)
        return apply_case(trait, input_char, base_char, ENC)
    else
        # Handle unknown symbols
        trait = unknown_symbol_handling_trait(cipher)
        return transform_symbol(trait, input_char)
    end

end

# Define how cipher types operate

"""
    (cipher::AbstractStreamCipherConfiguration)(plain_char::Char) -> Char

Encrypts or decrypts a single character `plain_char` using the given `cipher` of type `AbstractStreamCipherConfiguration`.

# Arguments
- `cipher::AbstractStreamCipherConfiguration`: The stream cipher used for transformation.
- `plain_char::Char`: The character to be encrypted or decrypted.

# Returns
- `Char`: The transformed character after applying the stream cipher.
"""
(cipher::AbstractStreamCipherConfiguration)(plain_char::Char) =
    process_char!(cipher.state, cipher, plain_char)

"""
    (cipher::AbstractStreamCipherConfiguration)(text::AbstractString) -> String

Applies the `AbstractStreamCipherConfiguration` transformation to each character in the given `text` string and returns the resulting transformed string.

# Arguments
- `cipher::AbstractStreamCipherConfiguration`: The stream cipher instance used for the transformation.
- `text::AbstractString`: The input text to be transformed.

# Returns
- `String`: The transformed string after applying the stream cipher to each character.
"""
function (cipher::AbstractStreamCipherConfiguration)(text::AbstractString)
    isempty(text) && return ""
    CIPHER_CONFIG = typeof(cipher)
    if :key in fieldnames(CIPHER_CONFIG)
        isempty(cipher.key) && return ""
    end
    state = State(cipher)
    join(process_char!(state, cipher, c) for c in text)
end


#abstract type AbstractStreamCipherConfigurationParameters end
#abstract type AbstractStreamCipherConfigurationState end

"""
    AbstractStreamCipher{T} <: OnlineStat{T}

Abstract type representing a stream cipher that implements the OnlineStat API.

This type serves as a base for implementing stream ciphers that process data sequentially
using the online statistics framework. The type parameter `T` specifies the type of data
being processed by the cipher.

# Type Parameters
- `T`: The type of data being processed by the cipher
"""
abstract type AbstractStreamCipher{T} <: OnlineStat{T} end


"""
    _fit!(cipher::CIPHER, data) where {CIPHER<:AbstractStreamCipher}

Internal method to fit/process data through a stream cipher. This is an implementation of
OnlineStatsBase's `_fit!` interface for stream ciphers.

# Arguments
- `cipher::CIPHER`: The stream cipher instance to process data through
- `data`: The input data to be processed by the cipher

# Notes
- This is an internal method and not meant to be called directly by users
- The function modifies the cipher's internal state based on the input data
"""
function OnlineStatsBase._fit!(cipher::CIPHER, data) where {CIPHER<:AbstractStreamCipher}
    cipher.n += 1
    cipher.value = process_char!(cipher.state, cipher.configuration, data)
    fit_listeners!(cipher)
end

"""
    fit_listeners!(cipher::O) where {O<:AbstractStreamCipher}

Initialize and attach any required listeners to the given stream cipher implementation.
This function should be called before using the cipher to ensure proper event handling.

# Arguments
- `cipher::O`: A stream cipher instance that implements the AbstractStreamCipher interface

# Returns
Nothing. Modifies the cipher object in place.

# Note
This is an internal function used to set up event handling for stream ciphers.
Specific cipher implementations may override this method to add custom listeners.
"""
function fit_listeners!(cipher::O) where {O<:AbstractStreamCipher}
    for listener in cipher.output_listeners.stats
        fit!(listener, cipher.value)
    end
end

"""
    connect!(cipher2::C2, cipher1::C1) where {C2<:AbstractStreamCipher, C1<:AbstractStreamCipher}

Connect two stream ciphers, allowing the output of `cipher1` to be sent as input to `cipher2`.

# Comment
Be sure to call this function before using the ciphers to ensure proper data flow.
By connecting ciphers, you can create complex cipher chains and data processing pipelines.
But be careful to avoid circular dependencies or infinite loops.

# ToDo: using a DAG (Directed Acyclic Graph) to manage the connections should be considered for more complex scenarios.
# Consider following discussion: https://github.com/joshday/OnlineStats.jl/issues/272 about OnlineStat chaining
"""
function connect!(
    cipher2::C2,
    cipher1::C1,
) where {C2<:AbstractStreamCipher,C1<:AbstractStreamCipher}
    if length(cipher1.output_listeners.stats) > 0
        cipher1.output_listeners = merge(cipher1.output_listeners, cipher2)
    else
        cipher1.output_listeners = Series(cipher2)
    end
end



mutable struct StreamCipher{CIPHER_CONFIG,Tin} <: AbstractStreamCipher{Tin}
    value::Union{Missing,Tin}
    n::Int

    output_listeners::Series
    input_cipher::Union{Missing,AbstractStreamCipher}

    configuration::CIPHER_CONFIG
    state::Any
end

# Type-parameterized constructor
function StreamCipher{Tin}(
    cipher::CIPHER_CONFIG,
) where {CIPHER_CONFIG<:AbstractStreamCipherConfiguration,Tin}
    state = State(cipher)
    StreamCipher{CIPHER_CONFIG,Tin}(missing, 0, Series(), missing, cipher, state)
end

# Default constructor using Char as default type parameter
function StreamCipher(
    cipher::CIPHER_CONFIG,
) where {CIPHER_CONFIG<:AbstractStreamCipherConfiguration}
    StreamCipher{Char}(cipher)
end
