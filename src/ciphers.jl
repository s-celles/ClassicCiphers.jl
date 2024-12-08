
"""
A module containing classic cipher implementations for text encryption and decryption.

This module provides functions to work with various historical and classic ciphers,
allowing users to encrypt and decrypt text using different cipher algorithms.

# Module Contents
- Cipher implementation functions
- Encryption and decryption utilities
- Helper functions for cipher operations
"""
module Ciphers

export inv
import Base: inv

#using ClassicCiphers: AbstractStreamCipherConfiguration
import ClassicCiphers.Alphabet: AlphabetParameters
import ClassicCiphers.Traits: is_remove, is_ignore
import ClassicCiphers.Traits:
    iscasesensitive,
    output_case_handling_trait,
    apply_case,
    unknown_symbol_handling_trait,
    transform_symbol

include("ciphers/common/stream_ciphers.jl")  # Base stream cipher functionality

# Include all cipher implementations

include("ciphers/formatting.jl")    # Formatting tools
include("ciphers/substitution.jl")  # Base substitution cipher
include("ciphers/rot13.jl")         # ROT13 cipher implementation
include("ciphers/caesar.jl")        # Caesar cipher implementation
include("ciphers/affine.jl")        # affine cipher implementation
include("ciphers/xor.jl")           # xor cipher implementation
include("ciphers/vigenere.jl")      # Vigenere cipher implementation
include("ciphers/vernam.jl")        # Vernam cipher implementation

end
