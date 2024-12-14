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
        plaintext = "HELLO WORLD"
        codetext = ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."
        @test morse(plaintext) == codetext
        
        # Test decoding
        demorse = inv(morse)
        @test demorse(codetext) == plaintext
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
                plaintext = "SOS",
                codetext = "... --- ..."
            ),
            (
                plaintext = "HELLO WORLD",
                codetext = ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."
            ),
            (
                plaintext = "THE QUICK BROWN FOX",
                codetext = "- .... . / --.- ..- .. -.-. -.- / -... .-. --- .-- -. / ..-. --- -..-"
            ),
            (
                plaintext = "the quick brown fox",
                codetext = "- .... . / --.- ..- .. -.-. -.- / -... .-. --- .-- -. / ..-. --- -..-"
            )
        ]
        
        morse = MorseCode()
        demorse = inv(morse)
        
        for (plaintext, codetext) in test_vectors
            @test morse(plaintext) == codetext
            @test uppercase(plaintext) == demorse(codetext)  # Decoding always returns uppercase
        end
    end
end