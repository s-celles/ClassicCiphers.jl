import ClassicCiphers.Ciphers: XORCipher
import ClassicCiphers.Alphabet: AlphabetParameters

@testset "XORCipher" begin
    @testset "Classical test vectors" begin
        test_vectors = [
            # Test vector 1: Classical example
            (
                plaintext = Vector{UInt8}("ATTACKATDAWN"),
                key = Vector{UInt8}("LEMON"),
                ciphertext = UInt8[
                    0x0d,
                    0x11,
                    0x19,
                    0x0e,
                    0x0d,
                    0x07,
                    0x04,
                    0x19,
                    0x0b,
                    0x0f,
                    0x1b,
                    0x0b,
                ],
            ),

            # Test vector 2
            (
                plaintext = Vector{UInt8}("CRYPTOGRAPHY"),
                key = Vector{UInt8}("SECRET"),
                ciphertext = UInt8[
                    0x10,
                    0x17,
                    0x1a,
                    0x02,
                    0x11,
                    0x1b,
                    0x14,
                    0x17,
                    0x02,
                    0x02,
                    0x0d,
                    0x0d,
                ],
            ),

            # Test vector 3
            (
                plaintext = Vector{UInt8}("TOBEORNOTTOBE"),
                key = Vector{UInt8}("KEY"),
                ciphertext = UInt8[
                    0x1f,
                    0x0a,
                    0x1b,
                    0x0e,
                    0x0a,
                    0x0b,
                    0x05,
                    0x0a,
                    0x0d,
                    0x1f,
                    0x0a,
                    0x1b,
                    0x0e,
                ],
            ),
        ]

        for (plaintext, key, expected) in test_vectors
            cipher = XORCipher(key)
            ciphertext = cipher(plaintext)

            # Test encryption
            @test ciphertext == expected

            # Test decryption
            @test cipher(ciphertext) == plaintext

            # Test XOR operation byte by byte
            for i in eachindex(plaintext)
                key_idx = mod1(i, length(key))
                @test ciphertext[i] == plaintext[i] ⊻ key[key_idx]
            end
        end
    end

    @testset "Basic operations" begin
        key = Vector{UInt8}("KEY")
        cipher = XORCipher(key)

        plaintext = Vector{UInt8}("HELLO")
        ciphertext = cipher(plaintext)

        @test ciphertext != plaintext
        @test length(ciphertext) == length(plaintext)
        @test cipher(ciphertext) == plaintext
    end

    @testset "Key cycling" begin
        key = Vector{UInt8}("AB")
        cipher = XORCipher(key)

        plaintext = Vector{UInt8}("XYZ")
        ciphertext = cipher(plaintext)

        @test ciphertext[1] == (plaintext[1] ⊻ key[1])
        @test ciphertext[2] == (plaintext[2] ⊻ key[2])
        @test ciphertext[3] == (plaintext[3] ⊻ key[1])  # Key wraps
    end

    @testset "Empty and edge cases" begin
        key = Vector{UInt8}("KEY")
        cipher = XORCipher(key)

        @test cipher(Vector{UInt8}("")) == Vector{UInt8}("")
        @test_throws ArgumentError XORCipher(Vector{UInt8}(""))

        # Single character
        @test length(cipher(Vector{UInt8}("A"))) == 1
    end

    @testset "Type preservation" begin
        key = Vector{UInt8}("A")
        cipher = XORCipher(key)
        msg = Vector{UInt8}("ABC")

        result = cipher(msg)
        @test eltype(result) == UInt8
        @test typeof(result) == Vector{UInt8}
    end

    @testset "stream API" begin
        key = Vector{UInt8}("LEMON")
        cipher = XORCipher(key)
        stream_cipher = StreamCipher{UInt8}(cipher)
        fit!(stream_cipher, UInt8('A'))
        @test value(stream_cipher) == 0x0d
        fit!(stream_cipher, UInt8('T'))
        @test value(stream_cipher) == 0x11
        fit!(stream_cipher, UInt8('T'))
        @test value(stream_cipher) == 0x19
        fit!(stream_cipher, UInt8('A'))
        @test value(stream_cipher) == 0x0e
        fit!(stream_cipher, UInt8('C'))
        @test value(stream_cipher) == 0x0d
        fit!(stream_cipher, UInt8('K'))
        @test value(stream_cipher) == 0x07
    end
end
