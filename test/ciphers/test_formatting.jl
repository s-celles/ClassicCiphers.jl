import ClassicCiphers.Ciphers: FormattingCipher

@testset "FormattingCipher" begin
    @testset "Basic functionality" begin
        cipher = FormattingCipher()
        
        # Test empty string
        @test cipher("") == ""
        
        # Test string shorter than block size
        @test cipher("HELL") == "HELL"
        
        # Test string equal to block size
        @test cipher("HELLO") == "HELLO"
        
        # Test string longer than block size
        @test cipher("HELLOWORLD") == "HELLO WORLD"
        
        # Test multiple blocks
        @test cipher("THISISASECRETMESSAGE") == "THISI SASEC RETME SSAGE"
    end
    
    #@testset "Custom configurations" begin
    #    # Test different block sizes
    #    cipher = FormattingCipher(block_size=3)
    #    @test cipher("HELLOWORLD") == "HEL LOW ORL D"
    #    
    #    # Test different separator
    #    cipher = FormattingCipher(separator="-")
    #    @test cipher("SECRETMESSAGE") == "SECRE-TMESS-AGE"
    #    
    #    # Test multiple character separator
    #    cipher = FormattingCipher(separator=" | ")
    #    @test cipher("HELLOWORLD") == "HELLO | WORLD"
    #end
    #
    #@testset "Special character handling" begin
    #    cipher = FormattingCipher()
    #    
    #    # Test spaces in input
    #    @test cipher("HELLO WORLD") == "HELLO WORLD"
    #    
    #    # Test punctuation
    #    @test cipher("HELLO, WORLD!") == "HELLO WORLD"
    #    
    #    # Test mixed input
    #    @test cipher("Hi! This is 123.") == "HITHI SIS12 3"
    #end
    #
    #@testset "Inverse operation" begin
    #    cipher = FormattingCipher()
    #    decipher = inv(cipher)
    #    
    #    test_cases = [
    #        "HELLO",
    #        "THISISASECRETMESSAGE",
    #        "THE QUICK BROWN FOX",
    #        "Testing 123!",
    #    ]
    #    
    #    for text in test_cases
    #        formatted = cipher(text)
    #        unformatted = decipher(formatted)
    #        # Compare after removing spaces and punctuation from original
    #        cleaned = join(c for c in uppercase(text) if !isspace(c) && !ispunct(c))
    #        @test unformatted == cleaned
    #    end
    #end
    #
    #@testset "Error handling" begin
    #    # Test invalid block size
    #    @test_throws ArgumentError FormattingCipher(block_size=0)
    #    @test_throws ArgumentError FormattingCipher(block_size=-1)
    #end
    #
    #@testset "stream API" begin
    #    cipher = FormattingCipher(block_size=3)
    #    stream_cipher = StreamCipher(cipher)
    #    
    #    # Feed characters one by one
    #    fit!(stream_cipher, 'H')
    #    fit!(stream_cipher, 'E')
    #    fit!(stream_cipher, 'L')
    #    @test value(stream_cipher) == "HEL "
    #    
    #    fit!(stream_cipher, 'L')
    #    fit!(stream_cipher, 'O')
    #    fit!(stream_cipher, 'W')
    #    @test value(stream_cipher) == "LOW "
    #end
end