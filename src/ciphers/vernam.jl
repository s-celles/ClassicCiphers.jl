"""
    VernamCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}

A structure representing the Vernam cipher, also known as the one-time pad.

The Vernam cipher is a symmetric stream cipher where each character of the plaintext is combined
with a character from a random key stream using bitwise XOR operation. When used with a truly random
key the same length as the message, it provides perfect secrecy.

# Type Parameters
- `ENC`: Encoding type parameter that specifies how the text should be encoded

# Notes
- The key must be at least as long as the message to be encrypted
- Each key should be used only once
- The key should be truly random for perfect secrecy

See also: [`AbstractStreamCipherConfiguration`](@ref)
"""
struct VernamCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}
    key::String
    alphabet_params::AlphabetParameters

    function VernamCipher{ENC}(key::String, alphabet_params::AlphabetParameters) where {ENC}
        isempty(key) && throw(ArgumentError("Key cannot be empty"))
        new{ENC}(key, alphabet_params)
    end
end

"""
    VernamCipher(key::String; alphabet_params=AlphabetParameters())

Create a Vernam cipher instance with the specified key.

The Vernam cipher is a symmetric stream cipher where each character of the plaintext
is combined with a corresponding character from the key using modular addition.

# Arguments
- `key::String`: The key to be used for encryption/decryption. The key should be at least
  as long as the messages to be encrypted.
- `alphabet_params::AlphabetParameters=AlphabetParameters()`: Optional parameters defining
  the alphabet and character mapping for the cipher.

# Returns
- A `VernamCipher` instance configured with the provided key and alphabet parameters.
"""
function VernamCipher(key::String; alphabet_params = AlphabetParameters())
    VernamCipher{true}(key, alphabet_params)
end


State(cipher::VernamCipher) = ValidCharCount()

"""
    transform_char(cipher::VernamCipher{ENC}, input_char::Char, state::AbstractCipherState) where {ENC}

Transform a single character using the Vernam cipher in the specified mode (encryption/decryption).

# Arguments
- `cipher::VernamCipher{ENC}`: The Vernam cipher instance with encryption/decryption type parameter
- `input_char::Char`: The character to be transformed
- `state::AbstractCipherState`: The current state of the cipher

# Returns
The transformed character

# Note
The transformation applies bitwise XOR operation between the input character and the key character at the current position.
"""
function transform_char(cipher::VernamCipher{ENC}, input_char::Char, state::AbstractCipherState) where {ENC}
    alphabet = cipher.alphabet_params.alphabet
    alphabet_size = length(alphabet)
    
    # Get current key character
    key_char = cipher.key[mod1(state.valid_char_count + 1, length(cipher.key))]
    
    # Find positions in alphabet
    char_pos = findfirst(==(input_char), alphabet)
    key_pos = findfirst(==(key_char), alphabet)
    
    if char_pos === nothing || key_pos === nothing
        # Handle unknown symbols
        trait = unknown_symbol_handling_trait(cipher)
        return transform_symbol(trait, input_char)
    else
        # Apply Vernam transformation
        out_idx = if ENC
            mod(char_pos + key_pos - 2, alphabet_size)
        else
            mod(char_pos - key_pos + alphabet_size, alphabet_size)
        end
        
        # Get transformed character and apply case rules
        base_char = alphabet[out_idx + 1]
        trait = output_case_handling_trait(cipher)
        result = apply_case(trait, input_char, base_char, ENC)
        
        # Update state
        state.valid_char_count += 1
        
        return result
    end
end

"""
    inv(cipher::VernamCipher{ENC}) where {ENC}

Creates and returns a new Vernam cipher that is the inverse operation of the input cipher.
For a Vernam cipher, the inverse operation uses the same key but with opposite encryption direction
(encryption ↔ decryption).

# Arguments
- `cipher::VernamCipher{ENC}`: The Vernam cipher to be inverted

# Returns
- `VernamCipher`: A new Vernam cipher that performs the inverse operation
"""
function inv(cipher::VernamCipher{ENC}) where {ENC}
    VernamCipher{!ENC}(cipher.key, cipher.alphabet_params)
end
