"""
    CaesarCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}

Implementation of the Caesar cipher that shifts each letter by a fixed amount.

# Type parameters
- `ENC::Bool`: true for encryption, false for decryption

# Fields
- `shift::Int`: Number of positions to shift letters in the alphabet
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling
"""
struct CaesarCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}
    shift::Int
    alphabet_params::AlphabetParameters
end

"""
    CaesarCipher(; shift=3, alphabet_params=AlphabetParameters())

Construct a Caesar cipher for encryption with optional shift and alphabet parameters.

# Keywords
- `shift::Int`: Number of positions to shift (default: 3)
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling 
  (default: standard alphabet with default settings)

# Examples
```julia
# Default Caesar cipher (shift=3)
cipher = CaesarCipher()

# Caesar cipher with custom shift
cipher = CaesarCipher(shift=5)

# Caesar cipher with custom alphabet parameters
alphabet_params = AlphabetParameters(case_sensitive=true)
cipher = CaesarCipher(shift=3, alphabet_params=alphabet_params)
```
"""
CaesarCipher(; shift = 3, alphabet_params = AlphabetParameters()) =
    CaesarCipher{true}(shift, alphabet_params)


"""
    transform_index(cipher::CaesarCipher{ENC}, index::Int) where {ENC}

Transform a character position in the alphabet by shifting it according to the cipher's shift value.

# Type parameters
- `ENC::Bool`: true for encryption, false for decryption

# Arguments
- `cipher::CaesarCipher{ENC}`: The Caesar cipher instance
- `index::Int`: Original position in the alphabet (1-based)

# Returns
- `Int`: New position after applying the shift (1-based)

# Examples
```julia
cipher = CaesarCipher(shift=3)
transform_index(cipher, 1)  # Returns 4 (A -> D)
transform_index(cipher, 26) # Returns 3 (Z -> C)
```
"""
function transform_index(cipher::CaesarCipher, index::Int)
    return mod1(index + cipher.shift, length(cipher.alphabet_params.alphabet))
end

"""
    inv(cipher::CaesarCipher{ENC}) where {ENC}

Create an inverse cipher that decrypts messages encrypted with the original cipher.

The inverse cipher:
- Reverses the shift direction (-shift)
- Toggles the encryption flag
- Keeps the same alphabet parameters

# Arguments
- `cipher::CaesarCipher{ENC}`: The cipher to invert

# Returns
- `CaesarCipher{!ENC}`: A new Caesar cipher that decrypts messages encrypted with the input cipher

# Examples
```julia
# Create a cipher and its inverse
cipher = CaesarCipher(shift=3)
decipher = inv(cipher)

# They cancel each other out
plaintext = "HELLO"
ciphertext = cipher(plaintext)    # "KHOOR"
recovered_plaintext = decipher(ciphertext) # "HELLO"
```
"""
function inv(cipher::CaesarCipher{ENC}) where {ENC}
    CaesarCipher{!ENC}(-cipher.shift, cipher.alphabet_params)
end
