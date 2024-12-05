"""
    AffineCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}

Implementation of the Affine cipher that applies the transformation E(x) = (ax + b) mod m
where m is the alphabet size, a and b are the key parameters.

# Type parameters
- `ENC::Bool`: true for encryption, false for decryption

# Fields
- `a::Int`: Multiplicative coefficient (must be coprime with alphabet size)
- `b::Int`: Shift amount like in Caesar cipher
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling
"""
struct AffineCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}
    a::Int
    b::Int
    alphabet_params::AlphabetParameters
end

"""
    AffineCipher(; a=1, b=0, alphabet_params=AlphabetParameters())

Construct an Affine cipher for encryption with optional parameters.

# Keywords
- `a::Int`: Multiplicative coefficient (must be coprime with alphabet size)
- `b::Int`: Shift amount (default: 0)
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling

# Examples
```julia
# Create a Caesar cipher (a=1, b=3)
cipher = AffineCipher(a=1, b=3)

# Create a ROT13 cipher (a=1, b=13)
cipher = AffineCipher(a=1, b=13)

# Create an Atbash cipher (a=-1, b=25)
cipher = AffineCipher(a=-1, b=25)

# Create a general affine cipher
cipher = AffineCipher(a=5, b=8)
```
"""
function AffineCipher(; a = 1, b = 0, alphabet_params = AlphabetParameters())
    # Check that a is coprime with alphabet size
    m = length(alphabet_params.alphabet)
    if gcd(a, m) != 1
        throw(ArgumentError("'a' parameter ($a) must be coprime with alphabet size ($m)"))
    end
    AffineCipher{true}(a, b, alphabet_params)
end

"""
    transform_index(cipher::AffineCipher{ENC}, index::Int) where {ENC}

Transform a character position using the affine transformation E(x) = (ax + b) mod m
for encryption or D(x) = a⁻¹(x - b) mod m for decryption.

The decryption formula uses the modular multiplicative inverse of 'a'.

# Arguments
- `cipher::AffineCipher{ENC}`: The affine cipher instance
- `index::Int`: Original position in the alphabet (1-based)

# Returns
- `Int`: New position after applying the transformation (1-based)
"""
function transform_index(cipher::AffineCipher{ENC}, index::Int) where {ENC}
    m = length(cipher.alphabet_params.alphabet)
    x = index - 1  # Convert to 0-based for modular arithmetic
    y = mod(cipher.a * x + cipher.b, m)
    return y + 1  # Convert back to 1-based indexing
end

"""
    inv(cipher::AffineCipher{ENC}) where {ENC}

Create an inverse cipher that decrypts messages encrypted with the original cipher.

The inverse cipher:
- Uses the modular multiplicative inverse of 'a'
- Adjusts the shift parameter accordingly
- Preserves alphabet parameters

# Arguments
- `cipher::AffineCipher{ENC}`: The cipher to invert

# Returns
- `AffineCipher{!ENC}`: A new affine cipher for decryption

# Examples
```julia
# Create cipher and inverse
cipher = AffineCipher(a=5, b=8)
decipher = inv(cipher)

# They cancel each other out
message = "HELLO"
encrypted = cipher(message)
decrypted = decipher(encrypted) # Returns "HELLO"
```
"""
function inv(cipher::AffineCipher{ENC}) where {ENC}
    m = length(cipher.alphabet_params.alphabet)
    a_inv = invmod(cipher.a, m)
    b_inv = mod(-a_inv * cipher.b, m)
    AffineCipher{!ENC}(a_inv, b_inv, cipher.alphabet_params)
end
