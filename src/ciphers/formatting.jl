"""
    FormattingState <: AbstractCipherState

State for formatting operations, maintaining a buffer of characters being processed.

# Fields
- `buffer::Vector{Char}`: Accumulates characters until a block is complete
"""
struct FormattingState <: AbstractCipherState
    buffer::Vector{Char}
    
    FormattingState() = new(Char[])
end



"""
    FormattingCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}

A cipher that formats text into blocks of specified size, typically used for cipher text 
presentation. This cipher can be used to format encrypted text into standard groups 
(traditionally groups of 5 characters) or custom sized groups.

# Type parameters
- `ENC::Bool`: true for encryption (applies formatting), false for decryption (removes formatting)

# Fields
- `block_size::Int`: Number of characters per block (default: 5)
- `separator::String`: String used to separate blocks (default: " ")
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling

# Examples
```julia
# Create formatter with default settings (5-char blocks)
formatter = FormattingCipher()
formatter("THISISASECRETMESSAGE")  # Returns "THISI SASER CETME SSAGE"

# Custom block size of 3
formatter = FormattingCipher(block_size=3)
formatter("HELLOWORLD")  # Returns "HEL LOW ORL D"

# Custom separator
formatter = FormattingCipher(separator="-")
formatter("SECRETMESSAGE")  # Returns "SECRE-TMESS-AGE"
```
"""
struct FormattingCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}
    block_size::Int
    separator::String
    alphabet_params::AlphabetParameters

    function FormattingCipher{ENC}(
        block_size::Int,
        separator::String,
        alphabet_params::AlphabetParameters
    ) where {ENC}
        block_size > 0 || throw(ArgumentError("Block size must be positive"))
        new{ENC}(block_size, separator, alphabet_params)
    end
end

"""
    FormattingCipher(; block_size=5, separator=" ", alphabet_params=AlphabetParameters())

Create a formatting cipher for text grouping.

# Keywords
- `block_size::Int`: Number of characters per block (default: 5)
- `separator::String`: String used to separate blocks (default: " ")
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling
"""
function FormattingCipher(;
    block_size::Int = 5,
    separator::String = " ",
    alphabet_params::AlphabetParameters = AlphabetParameters()
)
    FormattingCipher{true}(block_size, separator, alphabet_params)
end


function flush_buffer(state::FormattingState, cipher::FormattingCipher, is_last::Bool=false)
    if isempty(state.buffer)
        return ""
    end
    result = join(state.buffer)
    # Add separator only if we have a full block and it's not the last one
    if length(state.buffer) == cipher.block_size && !is_last
        result *= cipher.separator
    end
    empty!(state.buffer)
    return result
end

"""
    State(cipher::FormattingCipher)

Create initial state for formatting cipher operation.
Returns a new FormattingState instance to track character accumulation.
"""
State(cipher::FormattingCipher) = FormattingState()

function process_char!(
    state::FormattingState,
    cipher::FormattingCipher{ENC},
    input_char::Char
) where {ENC}
    if ENC
        # For encryption (formatting), accumulate characters and add separators
        if !isspace(input_char) && !ispunct(input_char)
            push!(state.buffer, input_char)
            
            # If buffer reaches block size, format and clear
            if length(state.buffer) == cipher.block_size
                result = flush_buffer(state, cipher)
                return result
            end
            return ""
        else
            return ""
        end
    else
        # For decryption (unformatting), skip separators and pass through valid chars
        if input_char ∉ cipher.separator
            return input_char
        end
        return ""
    end
end

"""
    inv(cipher::FormattingCipher{ENC}) where {ENC}

Create an inverse formatting cipher that removes the formatting applied by the original cipher.

# Returns
- `FormattingCipher{!ENC}`: A new formatting cipher for unformatting

# Examples
```julia
# Create cipher and inverse
formatter = FormattingCipher()
unformatter = inv(formatter)

# They cancel each other out
message = "SECRETMESSAGE"
formatted = formatter(message)    # "SECRE TMESS AGE"
unformatted = unformatter(formatted)  # "SECRETMESSAGE"
```
"""
function inv(cipher::FormattingCipher{ENC}) where {ENC}
    FormattingCipher{!ENC}(
        cipher.block_size,
        cipher.separator,
        cipher.alphabet_params
    )
end

"""
    (cipher::FormattingCipher)(text::AbstractString) -> String

Apply formatting to input text by grouping characters into blocks.
Overrides the default implementation to handle final buffer flush.
"""
function (cipher::FormattingCipher)(text::AbstractString)
    isempty(text) && return ""
    state = State(cipher)
    result = IOBuffer()
    
    # Calculate the number of valid characters for block counting
    valid_chars = count(c -> !isspace(c) && !ispunct(c), text)
    chars_processed = 0
    
    # Process each character
    for c in text
        if !isspace(c) && !ispunct(c)
            chars_processed += 1
        end
        
        # Check if this will complete a block
        if length(state.buffer) == cipher.block_size - 1 && !isspace(c) && !ispunct(c)
            # If this completes a block, we need to know if it's the last full block
            is_last = chars_processed == valid_chars
            push!(state.buffer, c)
            write(result, flush_buffer(state, cipher, is_last))
        else
            write(result, process_char!(state, cipher, c))
        end
    end
    
    # Flush any remaining characters in buffer
    if !isempty(state.buffer)
        write(result, flush_buffer(state, cipher, true))  # true because it's definitely the last block
    end
    
    return String(take!(result))
end