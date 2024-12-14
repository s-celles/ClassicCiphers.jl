"""
    SubstitutionCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}

General substitution cipher that maps each character to another using a provided mapping.

# Type parameters
- `ENC::Bool`: true for encryption, false for decryption

# Fields
- `mapping::Dict{Char,Char}`: Character substitution mapping
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling
"""
struct SubstitutionCipher{ENC} <: AbstractStreamCipherConfiguration{ENC}
    mapping::Dict{Char,Char}
    alphabet_params::AlphabetParameters
end

"""
    SubstitutionCipher(mapping::Dict{Char,Char}; alphabet_params=AlphabetParameters())

Create a substitution cipher with a custom character mapping.

# Arguments
- `mapping::Dict{Char,Char}`: Dictionary mapping input characters to output characters

# Keywords
- `alphabet_params::AlphabetParameters`: Configuration for alphabet and case handling

# Examples
```julia
# Create a simple substitution cipher
mapping = Dict('A'=>'X', 'B'=>'Y', 'C'=>'Z')
cipher = SubstitutionCipher(mapping)
cipher("ABC")  # Returns "XYZ"
```
"""
function SubstitutionCipher(
    mapping::Dict{Char,Char};
    alphabet_params = AlphabetParameters(),
)
    SubstitutionCipher{true}(mapping, alphabet_params)
end

"""
    transform_index(cipher::SubstitutionCipher, index::Int)

Transforms a character index using the substitution mapping defined in the cipher.

# Arguments
- `cipher::SubstitutionCipher`: The substitution cipher containing the mapping
- `index::Int`: The index of the character to transform (1-based indexing)

# Returns
The transformed index according to the cipher's substitution mapping.
"""
function transform_index(cipher::SubstitutionCipher, index::Int)
    char = cipher.alphabet_params.alphabet[index]
    findfirst(==(cipher.mapping[char]), cipher.alphabet_params.alphabet)
end

"""
    inv(cipher::SubstitutionCipher{ENC}) where {ENC}

Create an inverse substitution cipher by reversing the character mapping.

The inverse cipher:
- Swaps each key-value pair in the mapping dictionary
- Preserves alphabet parameters
- Toggles the encryption flag

# Arguments
- `cipher::SubstitutionCipher{ENC}`: The cipher to invert

# Returns
- `SubstitutionCipher{!ENC}`: A new substitution cipher with reversed mapping

# Examples
```julia
# Create cipher and inverse
mapping = Dict('A'=>'X', 'B'=>'Y', 'C'=>'Z')
cipher = SubstitutionCipher(mapping)
decipher = inv(cipher)

# They cancel each other out
plaintext = "ABC"
ciphertext = cipher(plaintext)    # "XYZ"
recovered_plaintext = decipher(ciphertext) # "ABC"
```
"""
function inv(cipher::SubstitutionCipher{ENC}) where {ENC}
    # Create reverse mapping by swapping keys and values
    reverse_mapping = Dict(v => k for (k, v) in cipher.mapping)
    # Return new cipher with reversed mapping and toggled encryption flag
    SubstitutionCipher{!ENC}(reverse_mapping, cipher.alphabet_params)
end
