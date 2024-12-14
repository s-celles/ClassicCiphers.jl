"""
    ROT13Cipher{ENC} <: AbstractStreamCipherConfiguration{ENC}

ROT13 substitution cipher that shifts each letter by 13 positions.

A special case of the Caesar cipher with a fixed shift of 13, making it self-inverse
(applying the cipher twice returns the original text).

# Type parameters
- `ENC::Bool`: true for encryption, false for decryption

# Fields
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling
"""
struct ROT13Cipher{ENC} <: AbstractStreamCipherConfiguration{ENC}
    alphabet_params::AlphabetParameters
end

"""
    ROT13Cipher(; alphabet_params=AlphabetParameters())

Create a ROT13 cipher for encryption.

ROT13 is a special case of the Caesar cipher that:
- Uses a fixed shift of 13 positions
- Is its own inverse (applying it twice returns the original text)
- Works symmetrically on the standard Latin alphabet (A->N, B->O, etc.)

# Keywords
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling 
  (default: standard alphabet with default settings)

# Examples
```julia
# Default ROT13 cipher
cipher = ROT13Cipher()
cipher("HELLO")  # Returns "URYYB"

# ROT13 with case preservation
params = AlphabetParameters(output_contains_source_case=true)
cipher = ROT13Cipher(alphabet_params=params)
cipher("Hello")  # Returns "Uryyb"

# ROT13 is self-inverse
cipher(cipher("Hello"))  # Returns "Hello"
```
"""
ROT13Cipher(; alphabet_params = AlphabetParameters()) = ROT13Cipher{true}(alphabet_params)

function transform_index(cipher::ROT13Cipher, index::Int)
    return mod1(index + 13, length(cipher.alphabet_params.alphabet))
end

"""
    inv(cipher::ROT13Cipher{ENC}) where {ENC}

Create an inverse ROT13 cipher. Since ROT13 is self-inverse (shifting by 13 twice returns 
to the original position), the inverse only toggles the encryption flag while keeping the 
same shift.

# Arguments
- `cipher::ROT13Cipher{ENC}`: The cipher to invert

# Returns
- `ROT13Cipher{!ENC}`: A new ROT13 cipher with toggled encryption flag

# Examples
```julia
# Create cipher and inverse
cipher = ROT13Cipher()
decipher = inv(cipher)

# Both perform the same transformation
plaintext = "HELLO"
ciphertext1 = cipher(plaintext)     # "URYYB"
ciphertext2 = decipher(plaintext)   # "URYYB"

# Applying either twice returns original
cipher(cipher(plaintext))  # "HELLO"
```
"""
function inv(cipher::ROT13Cipher{ENC}) where {ENC}
    ROT13Cipher{!ENC}(cipher.alphabet_params)
end
