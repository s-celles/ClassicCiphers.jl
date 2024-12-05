"""
    module Traits

A module containing type traits for classification and operations on classical ciphers.

This module provides a system of traits to define and categorize different types of
classical cryptographic ciphers, their characteristics, and operations.
"""
module Traits

using ClassicCiphers: AbstractCipher

abstract type CipherTrait end

# Include specific trait types
include("traits/cipher_type.jl")    # Substitution, Transposition, etc.
include("traits/input_case.jl")     # Case sensitivity
include("traits/output_case.jl")    # Case preservation/conversion
include("traits/symbol.jl")         # Unknown symbol handling

# Default trait behaviors
function cipher_type_trait(cipher::AbstractCipher)
    cipher.alphabet_params.cipher_type
end

function output_case_handling_trait(cipher::AbstractCipher)
    cipher.alphabet_params.case_memorization
end

function unknown_symbol_handling_trait(cipher::AbstractCipher)
    cipher.alphabet_params.unknown_symbol_handling
end

end
