import ClassicCiphers.Ciphers: AffineCipher, CaesarCipher, ROT13Cipher
import ClassicCiphers.Alphabet: AlphabetParameters

@testset "AffineCipher" begin
    @testset "Constructor validation" begin
        # Test valid cases
        @test_nowarn AffineCipher(a = 1, b = 0)  # Identity
        @test_nowarn AffineCipher(a = 5, b = 8)  # Coprime with 26

        # Test invalid cases
        @test_throws ArgumentError AffineCipher(a = 2, b = 0)  # 2 not coprime with 26
        @test_throws ArgumentError AffineCipher(a = 13, b = 0) # 13 not coprime with 26
    end

    @testset "Special cases" begin
        # Test case 1: Caesar cipher (a=1, b=3)
        @testset "Caesar cipher comparison" begin
            # Create both cipher types
            caesar = CaesarCipher(shift = 3)
            affine = AffineCipher(a = 1, b = 3)

            # Test on full alphabet
            @test affine("ABCDEFGHIJKLMNOPQRSTUVWXYZ") ==
                  caesar("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

            # Test on specific messages
            test_msgs = [
                "HELLO WORLD",
                "THE QUICK BROWN FOX",
                "TESTING CAESAR",
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            ]

            for plain_msg in test_msgs
                @test affine(plain_msg) == caesar(plain_msg)

                # Test decryption also matches
                ciphered_msg = caesar(plain_msg)
                @test inv(affine)(ciphered_msg) == inv(caesar)(ciphered_msg)
            end

            # Test with different alphabet parameters
            ap_kwargs = Dict(
                :case_sensitivity => NOT_CASE_SENSITIVE,
                :output_case_mode => PRESERVE_CASE,
            )
            alphabet_params = AlphabetParameters(; ap_kwargs...)
            caesar = CaesarCipher(shift = 3, alphabet_params = alphabet_params)
            affine = AffineCipher(a = 1, b = 3, alphabet_params = alphabet_params)

            plain_msg = "Hello World!"
            @test affine(plain_msg) == caesar(plain_msg)
        end

        # Test case 2: ROT13 (a=1, b=13)
        @testset "ROT13 comparison" begin
            # Create both cipher types
            rot13 = ROT13Cipher()
            affine = AffineCipher(a = 1, b = 13)

            # Test on full alphabet
            @test affine("ABCDEFGHIJKLMNOPQRSTUVWXYZ") ==
                  rot13("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

            # Test on specific messages
            test_msgs = [
                "HELLO WORLD",
                "THE QUICK BROWN FOX",
                "TESTING ROT13",
                "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            ]

            for plain_msg in test_msgs
                @test affine(plain_msg) == rot13(plain_msg)

                # Test self-inverse property matches
                ciphered_msg = rot13(plain_msg)
                @test affine(affine(plain_msg)) == rot13(rot13(plain_msg))
                @test affine(ciphered_msg) == plain_msg
            end

            # Test with different alphabet parameters
            ap_kwargs = Dict(
                :case_sensitivity => NOT_CASE_SENSITIVE,
                :output_case_mode => PRESERVE_CASE,
            )
            alphabet_params = AlphabetParameters(; ap_kwargs...)
            rot13 = ROT13Cipher(alphabet_params = alphabet_params)
            affine = AffineCipher(a = 1, b = 13, alphabet_params = alphabet_params)

            plain_msg = "Hello World!"
            @test affine(plain_msg) == rot13(plain_msg)
        end

        # Test case 3: Atbash cipher (a=-1, b=25)
        @testset "Atbash" begin
            cipher = AffineCipher(a = -1, b = 25)
            @test cipher("ABCDEFGHIJKLMNOPQRSTUVWXYZ") == "ZYXWVUTSRQPONMLKJIHGFEDCBA"

            plain_msg = "HELLO WORLD"
            ciphered_msg = cipher(plain_msg)
            @test ciphered_msg == "SVOOL DLIOW"

            # Atbash is self-inverse
            @test cipher(ciphered_msg) == plain_msg
        end
    end

    @testset "General affine cipher" begin
        # Test with a=5, b=8
        cipher = AffineCipher(a = 5, b = 8)

        # Test single characters
        @test cipher("A") == "I"  # (5*0 + 8) mod 26 = 8 -> I
        @test cipher("B") == "N"  # (5*1 + 8) mod 26 = 13 -> N

        # Test full message
        plain_msg = "HELLO WORLD"
        ciphered_msg = cipher(plain_msg)
        @test ciphered_msg == "RCLLA OAPLX"
        decipher = inv(cipher)
        decrypted = decipher(ciphered_msg)
        @test decrypted == plain_msg

        # Test with different case handling
        ap_kwargs = Dict(
            :case_sensitivity => NOT_CASE_SENSITIVE,
            :output_case_mode => PRESERVE_CASE,
        )
        alphabet_params = AlphabetParameters(; ap_kwargs...)
        cipher = AffineCipher(a = 5, b = 8, alphabet_params = alphabet_params)
        plain_msg = "Hello World!"
        ciphered_msg = cipher(plain_msg)
        @test ciphered_msg == "Rclla Oaplx!"
        @test inv(cipher)(ciphered_msg) == plain_msg
    end

    @testset "Known test vectors" begin
        # Test vectors from literature and other implementations
        test_vectors = [
            (a = 5, b = 8, plain_msg = "ATTACKATDAWN", ciphered_msg = "IZZISGIZXIOV"),
            (a = 3, b = 7, plain_msg = "HELLO", ciphered_msg = "CTOOX"),
            (
                a = 7,
                b = 3,
                plain_msg = "THE QUICK BROWN FOX",
                ciphered_msg = "GAF LNHRV KSXBQ MXI",
            ),
        ]

        for (a, b, plain_msg, ciphered_msg) in test_vectors
            cipher = AffineCipher(a = a, b = b)
            @test cipher(plain_msg) == ciphered_msg

            decipher = inv(cipher)
            @test decipher(ciphered_msg) == plain_msg
        end
    end

    @testset "stream API" begin
        cipher = AffineCipher(a = 7, b = 3)
        stream_cipher = StreamCipher(cipher)
        fit!(stream_cipher, 'T')
        @test value(stream_cipher) == 'G'
        fit!(stream_cipher, 'H')
        @test value(stream_cipher) == 'A'
        fit!(stream_cipher, 'E')
        @test value(stream_cipher) == 'F'
    end
end
