import ClassicCiphers.Ciphers: AffineCipher, CaesarCipher, ROT13Cipher
import ClassicCiphers.Alphabet: AlphabetParameters, UPPERCASE_LETTERS

@testset "AffineCipher" begin
    @testset "Constructor validation" begin
        # Test valid cases
        @test_nowarn AffineCipher(a = 1, b = 0)  # Identity
        @test_nowarn AffineCipher(a = 5, b = 8)  # Coprime with 26

        # Test invalid cases
        @test_throws ArgumentError AffineCipher(a = 2, b = 0)  # 2 not coprime with 26
        @test_throws ArgumentError AffineCipher(a = 13, b = 0) # 13 not coprime with 26
    end

    @testset "Pangram" begin
        plaintext = "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG"
        cipher = AffineCipher(a = 1, b = 3)
        ciphertext = cipher(plaintext)
        letters_in_ciphertext = Set(collect(ciphertext))
        delete!(letters_in_ciphertext, ' ')  # Remove spaces
        @test letters_in_ciphertext == Set(UPPERCASE_LETTERS)  # All letters of alphabet should be present because it's a pangram
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

            for plaintext in test_msgs
                @test affine(plaintext) == caesar(plaintext)

                # Test decryption also matches
                ciphertext = caesar(plaintext)
                @test inv(affine)(ciphertext) == inv(caesar)(ciphertext)
            end

            # Test with different alphabet parameters
            ap_kwargs = Dict(
                :case_sensitivity => NOT_CASE_SENSITIVE,
                :output_case_mode => PRESERVE_CASE,
            )
            alphabet_params = AlphabetParameters(; ap_kwargs...)
            caesar = CaesarCipher(shift = 3, alphabet_params = alphabet_params)
            affine = AffineCipher(a = 1, b = 3, alphabet_params = alphabet_params)

            plaintext = "Hello World!"
            @test affine(plaintext) == caesar(plaintext)
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

            for plaintext in test_msgs
                @test affine(plaintext) == rot13(plaintext)

                # Test self-inverse property matches
                ciphertext = rot13(plaintext)
                @test affine(affine(plaintext)) == rot13(rot13(plaintext))
                @test affine(ciphertext) == plaintext
            end

            # Test with different alphabet parameters
            ap_kwargs = Dict(
                :case_sensitivity => NOT_CASE_SENSITIVE,
                :output_case_mode => PRESERVE_CASE,
            )
            alphabet_params = AlphabetParameters(; ap_kwargs...)
            rot13 = ROT13Cipher(alphabet_params = alphabet_params)
            affine = AffineCipher(a = 1, b = 13, alphabet_params = alphabet_params)

            plaintext = "Hello World!"
            @test affine(plaintext) == rot13(plaintext)
        end

        # Test case 3: Atbash cipher (a=-1, b=25)
        @testset "Atbash" begin
            cipher = AffineCipher(a = -1, b = 25)
            @test cipher("ABCDEFGHIJKLMNOPQRSTUVWXYZ") == "ZYXWVUTSRQPONMLKJIHGFEDCBA"

            plaintext = "HELLO WORLD"
            ciphertext = cipher(plaintext)
            @test ciphertext == "SVOOL DLIOW"

            # Atbash is self-inverse
            @test cipher(ciphertext) == plaintext
        end
    end

    @testset "General affine cipher" begin
        # Test with a=5, b=8
        cipher = AffineCipher(a = 5, b = 8)

        # Test single characters
        @test cipher("A") == "I"  # (5*0 + 8) mod 26 = 8 -> I
        @test cipher("B") == "N"  # (5*1 + 8) mod 26 = 13 -> N

        # Test full message
        plaintext = "HELLO WORLD"
        ciphertext = cipher(plaintext)
        @test ciphertext == "RCLLA OAPLX"
        decipher = inv(cipher)
        recovered_plaintext = decipher(ciphertext)
        @test recovered_plaintext == plaintext

        # Test with different case handling
        ap_kwargs = Dict(
            :case_sensitivity => NOT_CASE_SENSITIVE,
            :output_case_mode => PRESERVE_CASE,
        )
        alphabet_params = AlphabetParameters(; ap_kwargs...)
        cipher = AffineCipher(a = 5, b = 8, alphabet_params = alphabet_params)
        plaintext = "Hello World!"
        ciphertext = cipher(plaintext)
        @test ciphertext == "Rclla Oaplx!"
        @test inv(cipher)(ciphertext) == plaintext
    end

    @testset "Known test vectors" begin
        # Test vectors from literature and other implementations
        test_vectors = [
            (a = 5, b = 8, plaintext = "ATTACKATDAWN", ciphertext = "IZZISGIZXIOV"),
            (a = 3, b = 7, plaintext = "HELLO", ciphertext = "CTOOX"),
            (
                a = 7,
                b = 3,
                plaintext = "THE QUICK BROWN FOX",
                ciphertext = "GAF LNHRV KSXBQ MXI",
            ),
        ]

        for (a, b, plaintext, ciphertext) in test_vectors
            cipher = AffineCipher(a = a, b = b)
            @test cipher(plaintext) == ciphertext

            decipher = inv(cipher)
            @test decipher(ciphertext) == plaintext
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
