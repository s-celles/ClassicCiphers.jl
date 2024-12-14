import ClassicCiphers.Ciphers: VernamCipher

#=
This test set is for testing the VernamCipher implementation.
It is part of the test suite for the ClassicCiphers package.
The tests within this block will verify the correctness of the VernamCipher functionality.
=#
@testset "VernamCipher" begin
    @testset "Basic functionality" begin
        # Test with matching key and text length
        key = "TESTKEY"
        cipher = VernamCipher(key)
        plaintext = "MESSAGE"
        ciphertext = cipher(plaintext)

        # Test encryption produces different output
        @test ciphertext != plaintext

        # Test encryption matches expected output
        @test ciphertext == "FIKLKKC"

        # Test decryption recovers original
        decipher = inv(cipher)
        @test decipher(ciphertext) == uppercase(plaintext)
    end

    @testset "other tests" begin
        test_vectors = [
            (
                plaintext = "WELCOME TO CRYPTO WORLD",
                key = "SECRET",
                expected_ciphertext = "OINTSFW XQ TVRHXQ NSKDH",
            ),
            # OverTheWire Krypton 6
            (
                plaintext = "SINGOGODDESSTHEANGEROFACHILLESSONOFPELEUSTHATBROUGHTCOUNTLESSILLSUPONTHEACHAEANSMANYABRAVESOULDIDITSENDHURRYINGDOWNTOHADESANDMANYAHERODIDITYIELDAPREYTODOGSANDVULTURESFORSOWERETHECOUNSELSOFJOVEFULFILLEDFROMTHEDAYONWHICHTHESONOFATREUSKINGOFMENANDGREATACHILL",
                key = "ITWASTHEBESTOFTIMESITWASTHEWORSTOFTIMESITWASTHEAGEOFWISDOMITWASTHEAGEOFFOOLISHNESSITWASTHEEPOCHOFBELIEFITWASTHEEPOCHOFINCREDULITYITWASTHESEASONOFLIGHTITWASTHESEASONOFDARKNESSITWASTHESPRINGOFHOPEITWASTHEWINTEROFDESPAIRWEHADEVERYTHINGBEFOREUSWEHADNOTHINGBEF",
                expected_ciphertext = "ABJGGZVHEIKLHMXIZKWZHBAUAPPHSJKHBTYXQPWCLPHSMIVOAKVYYWMQHXMLOIDEZYPURHMJOQSIWHAWESVRWBJTCIWDINKWIJXDMRIPNNRQBUKHDKPACMIQGJEQXXIGWIAARGWPHAXYASYRFAZKFMWWKGKTUHNYLLIESXIOICBAWJMMDEUHBRKTCABLXTCSUYTYELDXKJNWZMLVRFBSFLHQTDXOEVSISWYMYMHYLMSUFJGWJEUDJESTAIPNJPQ",
            ),
            # CrypTool test vector (ToDo: can't be used as it is)
            # (
            #     plaintext = "Franz jagt im komplett verwahrlosten Taxi quer durch Bayern",
            #     key = "das ist ein Key mit erlaubten Zeichen",
            #     expected_ciphertext = "IrsmHrC kBmhWdInyxEdxKkvysPeuq sAvlrmWaPhhINdvhqt1gF9NiRdvE"
            # )
        ]

        # Test each vector
        for (plaintext, key, expected_ciphertext) in test_vectors
            ap_kwargs = Dict(
                :case_sensitivity => NOT_CASE_SENSITIVE,
                :output_case_mode => DEFAULT_CASE,
            )
            alphabet_params = AlphabetParameters(; ap_kwargs...)
            cipher = VernamCipher(key, alphabet_params = alphabet_params)

            # Test encryption
            ciphertext = cipher(plaintext)
            @test ciphertext == expected_ciphertext

            # Test decryption
            decipher = inv(cipher)
            @test decipher(ciphertext) == plaintext
        end
    end

    @testset "stream API" begin
        key = "TESTKEY"
        cipher = VernamCipher(key)
        stream_cipher = StreamCipher(cipher)
        fit!(stream_cipher, 'M')
        @test value(stream_cipher) == 'F'
        fit!(stream_cipher, 'E')
        @test value(stream_cipher) == 'I'
        fit!(stream_cipher, 'S')
        @test value(stream_cipher) == 'K'
    end

end
