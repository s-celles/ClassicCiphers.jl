"""
ClassicCiphers is a Julia module that implements various classical cryptographic ciphers.

This module provides functionality for encrypting and decrypting messages using traditional
cryptographic methods that were historically used before modern cryptography.

While these ciphers are not secure for modern use, they are valuable for educational purposes
and understanding the fundamentals of cryptography.
"""
module ClassicCiphers

export AlphabetParameters
export Ciphers
#export CaesarCipher, ROT13Cipher, SubstitutionCipher, VigenereCipher
#export VernamCipher

import Base: inv

# First include core types and traits
include("base.jl")      # AbstractCipher definition
include("traits.jl")    # All trait definitions
include("alphabet.jl")  # Alphabet parameters

# Then include cipher implementations
include("ciphers.jl")

end
