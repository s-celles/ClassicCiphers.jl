# Core type definitions and basic functionality
"""
    AbstractCipher{ACTION}

Abstract type for all ciphers in the package.

# Type parameters
- `ACTION::Bool`: true for encryption, false for decryption
"""
abstract type AbstractCipher{ACTION} end

"""
    AbstractStreamCipherConfiguration{ACTION} <: AbstractCipher{ACTION}

Abstract type for ciphers that process text as a continuous stream of characters.
"""
abstract type AbstractStreamCipherConfiguration{ACTION} <: AbstractCipher{ACTION} end

