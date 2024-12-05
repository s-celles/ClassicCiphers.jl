"""
    XORCipher{ENC, T} <: AbstractStreamCipherConfiguration{ENC}

Implementation of a XOR cipher that performs a bitwise XOR operation between message and key.

# Type parameters
- `ENC::Bool`: true for encryption, false for decryption
- `T`: Type of elements in the key vector

# Fields
- `key::Vector{T}`: The key used for XOR operation
"""
struct XORCipher{ENC,T} <: AbstractStreamCipherConfiguration{ENC}
    key::Vector{T}

    function XORCipher{ENC,T}(key::Vector{T}) where {ENC,T}
        isempty(key) && throw(ArgumentError("Key cannot be empty"))
        new{ENC,T}(key)
    end
end

"""
    XORCipher(key::Vector)

Create a XOR cipher for encryption with the given key.

# Arguments
- `key::Vector`: The key to use for XOR operations

# Examples
```julia
# Using byte array key
key = Vector{UInt8}("KEY")
cipher = XORCipher(key)
```
"""
function XORCipher(key::Vector{T}) where {T}
    XORCipher{true,T}(key)
end

State(cipher::XORCipher) = ValidCharCount()

"""
    transform_char(

Transforms a single character using XOR operation.

This function is intended to be used as part of XOR cipher operations, where each
character is transformed by applying the XOR operation with a corresponding key character.

# Arguments
- `char`: The character to be transformed
- `key_char`: The key character to XOR with

# Returns
The XORed character result
"""
function transform_char(
    cipher::XORCipher{ENC,T},
    input_char::UInt8,
    state::ValidCharCount,
) where {ENC,T}
    state.valid_char_count += 1
    key_idx = mod1(state.valid_char_count, length(cipher.key))
    key_char = cipher.key[key_idx]
    return input_char ⊻ key_char
end

"""
    (cipher::XORCipher)(msg::Vector)

Apply XOR cipher to input message using the initialized key.
The key is repeated as needed to match the message length.

# Arguments
- `cipher::XORCipher`: The XOR cipher instance
- `msg::Vector`: Message to encrypt/decrypt

# Returns
- `Vector`: XORed result of the same type as input
"""
function (cipher::XORCipher{ENC,T})(msg::Vector) where {ENC,T}
    isempty(msg) && return similar(msg)

    # XOR each element with repeated key
    state = State(cipher)
    result = similar(msg)
    for i in eachindex(msg)
        result[i] = transform_char(cipher, msg[i], state)
    end
    
    return result
end

"""
    inv(cipher::XORCipher{ENC, T}) where {ENC, T}

Create an inverse XOR cipher. Since XOR is its own inverse, this only toggles 
the encryption flag while keeping the same key.

# Returns
- `XORCipher{!ENC, T}`: A new XOR cipher with toggled encryption flag
"""
function inv(cipher::XORCipher{ENC,T}) where {ENC,T}
    XORCipher{!ENC,T}(cipher.key)
end
