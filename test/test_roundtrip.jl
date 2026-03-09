import ClassicCiphers.Ciphers:
    CaesarCipher, ROT13Cipher, AffineCipher, SubstitutionCipher,
    VigenereCipher, VernamCipher
import ClassicCiphers.Alphabet: AlphabetParameters

@testset "Roundtrip property tests" begin
    # Test texts with varying characteristics
    test_texts = [
        "HELLO",
        "A",
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
        "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG",
        "CRYPTOGRAPHY IS FUN",
        "AAAAAA",
        "ZZZ",
    ]

    @testset "CaesarCipher roundtrip" begin
        for shift in [0, 1, 3, 13, 25]
            cipher = CaesarCipher(shift = shift)
            decipher = inv(cipher)
            for text in test_texts
                @test decipher(cipher(text)) == uppercase(text)
            end
        end
    end

    @testset "ROT13Cipher roundtrip" begin
        cipher = ROT13Cipher()
        for text in test_texts
            # ROT13 is self-inverse
            @test cipher(cipher(text)) == uppercase(text)
            # Also test via inv
            @test inv(cipher)(cipher(text)) == uppercase(text)
        end
    end

    @testset "AffineCipher roundtrip" begin
        # (a, b) pairs where a is coprime with 26
        affine_params = [(1, 0), (1, 3), (1, 13), (5, 8), (7, 3), (3, 7), (25, 25)]
        for (a, b) in affine_params
            cipher = AffineCipher(a = a, b = b)
            decipher = inv(cipher)
            for text in test_texts
                @test decipher(cipher(text)) == uppercase(text)
            end
        end
    end

    @testset "SubstitutionCipher roundtrip" begin
        # Full alphabet substitution (reversed)
        forward = Dict(c => r for (c, r) in zip('A':'Z', reverse(collect('A':'Z'))))
        cipher = SubstitutionCipher(forward)
        decipher = inv(cipher)
        for text in test_texts
            @test decipher(cipher(text)) == uppercase(text)
        end
    end

    @testset "VigenereCipher roundtrip" begin
        keys = ["A", "KEY", "SECRET", "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
        for key in keys
            cipher = VigenereCipher(key)
            decipher = inv(cipher)
            for text in test_texts
                @test decipher(cipher(text)) == uppercase(text)
            end
        end
    end

    @testset "VernamCipher roundtrip" begin
        for text in test_texts
            # Use a key at least as long as the alphabetic chars in text
            alpha_len = count(c -> c in 'A':'Z' || c in 'a':'z', text)
            key = join('A' + (i % 26) for i in 0:max(alpha_len - 1, 0))
            isempty(key) && continue
            cipher = VernamCipher(key)
            decipher = inv(cipher)
            @test decipher(cipher(text)) == uppercase(text)
        end
    end
end
