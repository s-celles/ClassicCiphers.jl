"""
    VigenereCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}

Vigenère cipher implementation that uses a keyword to encrypt/decrypt text.
Each letter in the keyword determines the shift amount for the corresponding position in the text.

# Type parameters
- `ENC::Bool`: true for encryption, false for decryption

# Fields
- `key::String`: Keyword used for encryption/decryption
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling
"""
struct VigenereCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}
    key::String
    alphabet_params::AlphabetParameters
    key_indices::Vector{Int}  # Pre-calculated key indices for performance

    function VigenereCipher{ENC}(
        key::String,
        alphabet_params::AlphabetParameters,
    ) where {ENC}
        # Verify key is not empty
        isempty(key) && throw(ArgumentError("Key cannot be empty"))

        # Convert key to uppercase if not case sensitive
        processed_key =
            iscasesensitive(alphabet_params.case_sensitivity) ? key : uppercase(key)

        # Validate key contains only valid alphabet characters
        all(c -> c in alphabet_params.alphabet, processed_key) ||
            throw(ArgumentError("Key must only contain characters from the alphabet"))

        # Pre-calculate key indices
        key_indices = [findfirst(==(c), alphabet_params.alphabet) for c in processed_key]

        new{ENC}(processed_key, alphabet_params, key_indices)
    end
end

"""
    VigenereCipher(key::String; alphabet_params=AlphabetParameters())

Create a Vigenère cipher for encryption with the specified key.

# Arguments
- `key::String`: Keyword used for encryption/decryption

# Keywords
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling

# Examples
```julia
# Create Vigenère cipher with key "SECRET"
cipher = VigenereCipher("SECRET")
plaintext = "HELLO"
ciphertext = cipher(plaintext)  # Apply keyword-based shift

# Create cipher with custom alphabet parameters
params = AlphabetParameters(case_sensitive=true)
cipher = VigenereCipher("Key", alphabet_params=params)
```
"""
function VigenereCipher(key::String; alphabet_params = AlphabetParameters())
    VigenereCipher{true}(key, alphabet_params)
end

"""
    get_shift(cipher::VigenereCipher, pos::Int)

Get the shift value for the Vigenère cipher at the specified position in the key.
"""
function get_shift(cipher::VigenereCipher, pos::Int)
    # Use 1-based indexing and wrap around if position exceeds key length
    key_pos = mod1(pos, length(cipher.key_indices))
    # The shift is the key letter's position minus 1 (A=0, B=1, etc.)
    return cipher.key_indices[key_pos] - 1
end

State(cipher::VigenereCipher) = ValidCharCount()


function process_char!(
    state::ValidCharCount,
    cipher::VigenereCipher{ENC},
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

        # Get shift based on key character position (only counting valid chars)
        state.valid_char_count += 1
        shift = get_shift(cipher, state.valid_char_count)

        # Apply shift based on encryption/decryption
        # For encryption: (plain + key) mod 26
        # For decryption: (cipher - key + 26) mod 26
        shifted_index = if ENC
            mod1(index + shift, length(alphabet))
        else
            mod1(index - shift + length(alphabet), length(alphabet))
        end

        # Get the character at position `shifted_index` in the `alphabet` string.
        base_char = alphabet[shifted_index]

        # Apply output case rules
        trait = output_case_handling_trait(cipher)
        return apply_case(trait, input_char, base_char, ENC)
    else
        # Handle unknown symbols
        trait = unknown_symbol_handling_trait(cipher)
        return transform_symbol(trait, input_char)
    end
end


"""
    inv(cipher::VigenereCipher{ENC}) where {ENC}

Create an inverse Vigenère cipher by keeping the same key but toggling encryption mode.

The inverse cipher:
- Uses the same key
- Toggles the encryption flag
- Keeps the same alphabet parameters

# Arguments
- `cipher::VigenereCipher{ENC}`: The cipher to invert

# Returns
- `VigenereCipher{!ENC}`: A new Vigenère cipher for decryption

# Examples
```julia
# Create cipher and inverse
cipher = VigenereCipher("SECRET")
decipher = inv(cipher)

# They cancel each other out
plaintext = "HELLO"
ciphertext = cipher(plaintext)
recovered_plaintext = decipher(ciphertext) # Returns "HELLO"
```
"""
function inv(cipher::VigenereCipher{ENC}) where {ENC}
    VigenereCipher{!ENC}(cipher.key, cipher.alphabet_params)
end
