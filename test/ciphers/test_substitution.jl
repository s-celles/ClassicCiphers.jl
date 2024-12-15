import ClassicCiphers.Ciphers: SubstitutionCipher

#=
This test set is for testing the SubstitutionCipher implementation.
It is part of the test suite for the ClassicCiphers package.
The tests within this block will verify the correctness of the SubstitutionCipher functionality.
=#
@testset "SubstitutionCipher" begin
    @testset "Basic substitution" begin
        mapping = Dict('A' => 'X', 'B' => 'Y', 'C' => 'Z')
        cipher = SubstitutionCipher(mapping)
        @test cipher("ABC") == "XYZ"
        @test cipher("...") == "..."  # Unmapped characters preserved
    end

    @testset "Case handling" begin
        # Test case sensitivity with DEFAULT_CASE mode
        ap_kwargs = Dict(
            :case_sensitivity => CASE_SENSITIVE,
            :output_case_mode => DEFAULT_CASE,  # Changed from PRESERVE_CASE
        )
        mapping = Dict('A' => 'X', 'a' => 'x', 'B' => 'Y', 'b' => 'y')
        alphabet_params = AlphabetParameters(; ap_kwargs...)
        cipher = SubstitutionCipher(mapping, alphabet_params = alphabet_params)

        @test cipher("AaBb") == "XxYy"
        @test cipher("AABB") == "XXYY"
        @test cipher("aabb") == "xxyy"
    end

    @testset "Inverse operation" begin
        mapping = Dict('A' => 'X', 'B' => 'Y', 'C' => 'Z')
        cipher = SubstitutionCipher(mapping)
        decipher = inv(cipher)

        plaintext = "ABC"
        ciphertext = cipher(plaintext)
        @test ciphertext == "XYZ"
        @test decipher(ciphertext) == plaintext
    end

    @testset "Missing mappings" begin
        mapping = Dict('A' => 'X', 'B' => 'Y')
        cipher = SubstitutionCipher(mapping)
        @test cipher("ABC") == "XYC"  # Unmapped characters preserved
    end

    @testset "stream API" begin
        mapping = Dict('A' => 'X', 'B' => 'Y', 'C' => 'Z')
        cipher = SubstitutionCipher(mapping)
        stream_cipher = StreamCipher(cipher)
        fit!(stream_cipher, 'A')
        @test value(stream_cipher) == 'X'
        fit!(stream_cipher, 'B')
        @test value(stream_cipher) == 'Y'
        fit!(stream_cipher, 'C')
        @test value(stream_cipher) == 'Z'
    end
end
