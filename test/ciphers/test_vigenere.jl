import ClassicCiphers.Ciphers: VigenereCipher

#=
This test set is for testing the VigenereCipher implementation.
It is part of the test suite for the ClassicCiphers package.
The tests within this block will verify the correctness of the VigenereCipher functionality.
=#
@testset "VigenereCipher" begin
    @testset "Basic functionality" begin
        cipher = VigenereCipher("SECRET")

        # Test single character
        @test cipher("A") == "S"

        # Test simple word
        @test cipher("HELLO") == "ZINCS"

        # Test with spaces and punctuation
        @test cipher("HELLO WORLD!") == "ZINCS PGVNU!"
    end

    @testset "Key validation" begin
        # Test invalid key characters
        @test_throws ArgumentError VigenereCipher("SECRET!")
        @test_throws ArgumentError VigenereCipher("SECRET123")

        # Test empty key
        @test_throws ArgumentError VigenereCipher("")
    end

    @testset "Case handling" begin
        # Test case insensitive (default)
        cipher = VigenereCipher("Secret")
        @test cipher("Hello") == "ZINCS"

        # Test case sensitive
        ap_kwargs =
            Dict(:case_sensitivity => CASE_SENSITIVE, :output_case_mode => DEFAULT_CASE)
        alphabet_params = AlphabetParameters(; ap_kwargs...)
        cipher = VigenereCipher("Secret", alphabet_params = alphabet_params)
        @test cipher("Hello") != cipher("HELLO")

        # Test case preservation
        ap_kwargs = Dict(
            :case_sensitivity => NOT_CASE_SENSITIVE,
            :output_case_mode => PRESERVE_CASE,
        )
        alphabet_params = AlphabetParameters(; ap_kwargs...)
        cipher = VigenereCipher("SECRET", alphabet_params = alphabet_params)
        @test cipher("Hello World!") == "Zincs Pgvnu!"
    end

    @testset "Encryption/Decryption" begin
        key = "CIPHER"
        cipher = VigenereCipher(key)
        decipher = inv(cipher)

        # Test with various inputs
        test_cases = [
            "HELLO WORLD",
            "THE QUICK BROWN FOX",
            "CRYPTOGRAPHY",
            "A B C D E F G",
            "!!!SECRETS!!!",
            "12345",
        ]

        for plaintext in test_cases
            ciphertext = cipher(plaintext)
            recovered_plaintext = decipher(ciphertext)
            @test recovered_plaintext == uppercase(plaintext)
        end
    end

    @testset "Known examples" begin
        # Test vectors from external tools (CrypTool)
        cipher = VigenereCipher("SECRET")
        @test cipher("HELLO WORLD!") == "ZINCS PGVNU!"
    end

    #@testset "Key wraparound" begin
    #    # Short message with repeating key
    #    cipher = VigenereCipher("ABC")
    #    @test cipher("HHHHHH") == "HIHIHI"  # H + A, H + B, H + C, repeat
    #    
    #    # Message longer than key
    #    cipher = VigenereCipher("SECRET")
    #    @test cipher("AAAAAAAAAAAA") == "SECRETSECRET"  # Key repeats
    #end
    #
    #@testset "Special configurations" begin
    #    # Test with custom alphabet
    #    ap_kwargs = Dict(:alphabet=>collect('A':'M'))
    #    alphabet_params = AlphabetParameters(; ap_kwargs...)
    #    cipher = VigenereCipher("CAT", alphabet_params=alphabet_params)
    #    @test_throws ArgumentError cipher("XYZ")  # Letters not in alphabet
    #    
    #    # Test unknown symbol handling
    #    ap_kwargs = Dict(:unknown_symbol_handling=>REPLACE_SYMBOL)
    #    alphabet_params = AlphabetParameters(; ap_kwargs...)
    #    cipher = VigenereCipher("KEY", alphabet_params=alphabet_params)
    #    @test cipher("A1B2C3") == "K?E?Y?"
    #end

    # Sources of the test vectors:
    # http://courses.ece.ubc.ca/412/previous_years/2004/modules/sessions/EECE_412-03-crypto_intro-viewable.pdf
    # http://en.wikipedia.org/wiki/Vigenère_cipher
    # CrypTool1-Testvectors
    @testset "Others testset" begin
        test_vectors = [
            (n = 0, plaintext = "ATTACKATDAWN", key = "LEMON", expected_ciphertext = "LXFOPVEFRNHR"),
            (
                n = 0,
                plaintext = "CRYPTOISSHORTFORCRYPTOGRAPHY",
                key = "ABCD",
                expected_ciphertext = "CSASTPKVSIQUTGQUCSASTPIUAQJB",
            ),
            (
                n = 0,
                plaintext = "TOBEORNOTTOBETHATISTHEQUESTION",
                key = "RELATIONS",
                expected_ciphertext = "KSMEHZBBLKSMEMPOGAJXSEJCSFLZSY",
            ),
            (
                n = 0,
                plaintext = "BEIDERDISKUSSIONDERSICHERHEITEINESVERSCHLUESSELUNGSVERFAHRENSSOLLTEMANIMMERDAVONAUSGEHENDASSDERANGREIFERDASVERFAHRENKENNTABERNICHTDENSCHLUESSELDIEGOLDENEREGELDERKRYPTOGRAPHIEHEISSTUNTERSCHAETZENIEMALSDENKRYPTOANALYTIKEREINVERFAHRENFUERDESSENSICHERHEITMANAUFDIEGEHEIMHALTUNGDESALGORITHMUSANGEWIESENISTHATSCHWEREMAENGEL",
                key = "QWERTZUIOPASDFGHJKLYXCVBNM",
                expected_ciphertext = "RAMUXQXQGZUKVNUUMOCQFECFETUEXVBMYAJTRKFMRBNCDCIWIHFHUNJRAQYVGHODOYKTJXTKJGMENHEJELLFYPSCDSVXJLAKYEOGDGRDTWWMXQZIVGEFNJTUCKMCOPDDUFTARJVGFCSHSWOIOLPYWBBPZSRSUHHVKJLGDIOYUFVOROSCFUNUHZJAVJVGUMHOEFLJSHUCOCKMMZCFEWRREXNQYTRWLSBLAPLFOGIGHQHZIJLDHAWRHWUMKPCWLLXWAEVQWALVBLBIZIUFJIKZJVRMOKOIZGIWRXXVCMGTNAVYNHCCNFTGMFZMUJKVE",
            ),
        ]
        for (n, plaintext, key, expected_ciphertext) in test_vectors
            cipher = VigenereCipher(key)
            ciphertext = cipher(plaintext)
            @test ciphertext == expected_ciphertext
            decipher = inv(cipher)
            @test decipher(ciphertext) == plaintext
        end
    end

    @testset "stream API" begin
        key = "SECRET"
        cipher = VigenereCipher(key)
        stream_cipher = StreamCipher(cipher)
        fit!(stream_cipher, 'H')
        @test value(stream_cipher) == 'Z'
        fit!(stream_cipher, 'E')
        @test value(stream_cipher) == 'I'
        fit!(stream_cipher, 'L')
        @test value(stream_cipher) == 'N'
        fit!(stream_cipher, 'L')
        @test value(stream_cipher) == 'C'
        fit!(stream_cipher, 'O')
        @test value(stream_cipher) == 'S'
    end

end
