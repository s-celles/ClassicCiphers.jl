import ClassicCiphers.Ciphers: XORCipher
import ClassicCiphers.Alphabet: AlphabetParameters

@testset "XORCipher" begin
    @testset "Classical test vectors" begin
        test_vectors = [
            # Test vector 1: Classical example
            (
                plain_msg = Vector{UInt8}("ATTACKATDAWN"),
                key = Vector{UInt8}("LEMON"),
                ciphered_msg = UInt8[
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
                plain_msg = Vector{UInt8}("CRYPTOGRAPHY"),
                key = Vector{UInt8}("SECRET"),
                ciphered_msg = UInt8[
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
                plain_msg = Vector{UInt8}("TOBEORNOTTOBE"),
                key = Vector{UInt8}("KEY"),
                ciphered_msg = UInt8[
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

        for (plain_msg, key, expected) in test_vectors
            cipher = XORCipher(key)
            ciphered_msg = cipher(plain_msg)

            # Test encryption
            @test ciphered_msg == expected

            # Test decryption
            @test cipher(ciphered_msg) == plain_msg

            # Test XOR operation byte by byte
            for i in eachindex(plain_msg)
                key_idx = mod1(i, length(key))
                @test ciphered_msg[i] == plain_msg[i] ⊻ key[key_idx]
            end
        end
    end

    @testset "Basic operations" begin
        key = Vector{UInt8}("KEY")
        cipher = XORCipher(key)

        plain_msg = Vector{UInt8}("HELLO")
        ciphered_msg = cipher(plain_msg)

        @test ciphered_msg != plain_msg
        @test length(ciphered_msg) == length(plain_msg)
        @test cipher(ciphered_msg) == plain_msg
    end

    @testset "Key cycling" begin
        key = Vector{UInt8}("AB")
        cipher = XORCipher(key)

        plain_msg = Vector{UInt8}("XYZ")
        ciphered_msg = cipher(plain_msg)

        @test ciphered_msg[1] == (plain_msg[1] ⊻ key[1])
        @test ciphered_msg[2] == (plain_msg[2] ⊻ key[2])
        @test ciphered_msg[3] == (plain_msg[3] ⊻ key[1])  # Key wraps
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
