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
        plain_msg = "MESSAGE"
        encrypted = cipher(plain_msg)

        # Test encryption produces different output
        @test encrypted != plain_msg

        # Test encryption matches expected output
        @test encrypted == "FIKLKKC"

        # Test decryption recovers original
        decipher = inv(cipher)
        @test decipher(encrypted) == uppercase(plain_msg)
    end

    @testset "other tests" begin
        test_vectors = [
            (
                input = "WELCOME TO CRYPTO WORLD",
                key = "SECRET",
                output = "OINTSFW XQ TVRHXQ NSKDH",
            ),
            # OverTheWire Krypton 6
            (
                input = "SINGOGODDESSTHEANGEROFACHILLESSONOFPELEUSTHATBROUGHTCOUNTLESSILLSUPONTHEACHAEANSMANYABRAVESOULDIDITSENDHURRYINGDOWNTOHADESANDMANYAHERODIDITYIELDAPREYTODOGSANDVULTURESFORSOWERETHECOUNSELSOFJOVEFULFILLEDFROMTHEDAYONWHICHTHESONOFATREUSKINGOFMENANDGREATACHILL",
                key = "ITWASTHEBESTOFTIMESITWASTHEWORSTOFTIMESITWASTHEAGEOFWISDOMITWASTHEAGEOFFOOLISHNESSITWASTHEEPOCHOFBELIEFITWASTHEEPOCHOFINCREDULITYITWASTHESEASONOFLIGHTITWASTHESEASONOFDARKNESSITWASTHESPRINGOFHOPEITWASTHEWINTEROFDESPAIRWEHADEVERYTHINGBEFOREUSWEHADNOTHINGBEF",
                output = "ABJGGZVHEIKLHMXIZKWZHBAUAPPHSJKHBTYXQPWCLPHSMIVOAKVYYWMQHXMLOIDEZYPURHMJOQSIWHAWESVRWBJTCIWDINKWIJXDMRIPNNRQBUKHDKPACMIQGJEQXXIGWIAARGWPHAXYASYRFAZKFMWWKGKTUHNYLLIESXIOICBAWJMMDEUHBRKTCABLXTCSUYTYELDXKJNWZMLVRFBSFLHQTDXOEVSISWYMYMHYLMSUFJGWJEUDJESTAIPNJPQ",
            ),
            # CrypTool test vector (ToDo: can't be used as it is)
            # (
            #     input = "Franz jagt im komplett verwahrlosten Taxi quer durch Bayern",
            #     key = "das ist ein Key mit erlaubten Zeichen",
            #     output = "IrsmHrC kBmhWdInyxEdxKkvysPeuq sAvlrmWaPhhINdvhqt1gF9NiRdvE"
            # )
        ]

        # Test each vector
        for (input, key, output) in test_vectors
            ap_kwargs = Dict(
                :case_sensitivity => NOT_CASE_SENSITIVE,
                :output_case_mode => DEFAULT_CASE,
            )
            alphabet_params = AlphabetParameters(; ap_kwargs...)
            cipher = VernamCipher(key, alphabet_params = alphabet_params)

            # Test encryption
            c = cipher(input)
            @test c == output

            # Test decryption
            decipher = inv(cipher)
            @test decipher(c) == input  # Vérifie que le texte déchiffré est en majuscules
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
