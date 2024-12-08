import ClassicCiphers.Codes: MorseCode
import ClassicCiphers.Alphabet: AlphabetParameters

@testset "MorseCode" begin
    @testset "Basic encoding/decoding" begin
        morse = MorseCode()
        
        # Test single characters
        @test morse("A") == ".-"
        @test morse("E") == "."
        @test morse("T") == "-"
        
        # Test words
        @test morse("SOS") == "... --- ..."
        @test morse("HELLO") == ".... . .-.. .-.. ---"
        
        # Test full sentence with spaces
        plain_msg = "HELLO WORLD"
        ciphered_msg = ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."
        @test morse(plain_msg) == ciphered_msg
        
        # Test decoding
        demorse = inv(morse)
        @test demorse(ciphered_msg) == plain_msg
    end
    
    @testset "Case handling" begin
        morse = MorseCode()
        
        # Test lowercase
        @test morse("hello") == ".... . .-.. .-.. ---"
        @test morse("Hello World") == ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."
        
        # Test mixed case
        @test morse("HeLLo WoRLD") == ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."
    end
    
    @testset "Special characters" begin
        morse = MorseCode()
        
        # Test numbers
        @test morse("123") == ".---- ..--- ...--"
        
        # Test mixed alphanumeric
        @test morse("2A3B") == "..--- .- ...-- -..."
        
        # Test with spaces
        @test morse("123 456") == ".---- ..--- ...-- / ....- ..... -...."
    end
    
    @testset "Edge cases" begin
        morse = MorseCode()
        
        # Empty string
        @test morse("") == ""
        @test inv(morse)("") == ""
        
        # Multiple spaces should collapse to single "/"
        # @test morse("A  B") == ".- / -..."
        
        # Unknown characters should be ignored
        @test morse("A#B") == ".- -..."
    end
    
    @testset "Known messages" begin
        test_vectors = [
            (
                plain_msg = "SOS",
                morse = "... --- ..."
            ),
            (
                plain_msg = "HELLO WORLD",
                morse = ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."
            ),
            (
                plain_msg = "THE QUICK BROWN FOX",
                morse = "- .... . / --.- ..- .. -.-. -.- / -... .-. --- .-- -. / ..-. --- -..-"
            ),
            (
                plain_msg = "the quick brown fox",
                morse = "- .... . / --.- ..- .. -.-. -.- / -... .-. --- .-- -. / ..-. --- -..-"
            )
        ]
        
        morse = MorseCode()
        demorse = inv(morse)
        
        for (plain_msg, morse_code) in test_vectors
            @test morse(plain_msg) == morse_code
            @test uppercase(plain_msg) == demorse(morse_code) # Decoding always returns uppercase
        end
    end
end