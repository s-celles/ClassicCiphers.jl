#=
The following test sets are part of the test suite for the ClassicCiphers package.
=#

using ClassicCiphers
using Test

"""
In cryptography, there are common case conventions:

For alphabets:
- UPPERCASE letters are traditionally used for plaintext (the original message)
- lowercase letters are used for ciphertext (the encrypted message)

For example, using the Caesar cipher:
- Original message: "HELLO" (plaintext in uppercase)
- Encrypted message: "khoor" (ciphertext in lowercase)

This convention makes it easy to visually distinguish:
- What is input (UPPERCASE)
- What is output (lowercase)

This distinction is particularly useful in examples and explanations as it allows one to easily follow the message transformation process.
"""

@testset "ClassicCiphers.jl" begin

    include("tools/test_formatting.jl")
    include("ciphers/test_formatting.jl")
    include("ciphers/test_caesar.jl")
    include("ciphers/test_rot13.jl")
    include("ciphers/test_substitution.jl")
    include("ciphers/test_affine.jl")
    include("ciphers/test_xor.jl")
    include("ciphers/test_vigenere.jl")
    include("ciphers/test_vernam.jl")

end
