import ClassicCiphers.Tools.TextFormatting: group_text, ungroup_text

@testset "Text Formatting Utilities" begin
    @testset "group_text" begin
        @testset "Basic functionality" begin
            # Standard 5-character blocks
            @test group_text("ABCDEFGHIJ") == "ABCDE FGHIJ"
            @test group_text("THISISASECRETMESSAGE") == "THISI SASEC RETME SSAGE"
            
            # Incomplete final block
            @test group_text("ABCDEFGHI") == "ABCDE FGHI"
            @test group_text("HELLO") == "HELLO"
            
            # Single character
            @test group_text("A") == "A"
            
            # Empty string
            @test group_text("") == ""
        end
        
        @testset "Custom block sizes" begin
            # Block size of 3
            @test group_text("ABCDEFGHI", block_size=3) == "ABC DEF GHI"
            @test group_text("ABCDEFGHIJ", block_size=3) == "ABC DEF GHI J"
            
            # Block size of 2
            @test group_text("ABCDEF", block_size=2) == "AB CD EF"
            
            # Block size of 1
            @test group_text("ABC", block_size=1) == "A B C"
            
            # Block size larger than string
            @test group_text("ABC", block_size=5) == "ABC"
        end
        
        @testset "Custom separators" begin
            # Hyphen separator
            @test group_text("ABCDEFGHIJ", separator="-") == "ABCDE-FGHIJ"
            
            # Multiple character separator
            @test group_text("ABCDEFGHIJ", separator=" | ") == "ABCDE | FGHIJ"
            
            # Empty separator
            @test group_text("ABCDEFGHIJ", separator="") == "ABCDEFGHIJ"
            
            # Newline separator
            @test group_text("ABCDEFGHIJ", separator="\n") == "ABCDE\nFGHIJ"
        end
        
        @testset "Special characters handling" begin
            # Spaces in input
            @test group_text("ABC DEF GHI") == "ABCDE FGHI"
            
            # Punctuation
            @test group_text("ABC,DEF.GHI!") == "ABCDE FGHI"
            
            # Mixed case
            @test group_text("AbCdEfGhIj") == "AbCdE fGhIj"
            
            # Numbers
            @test group_text("ABC123DEF456") == "ABC12 3DEF4 56"
            
            # Special characters
            @test group_text("ABC@#DEF&*()") == "ABCDE F"
            
            # Mixed input with all types
            @test group_text("Hello, World! 123") == "Hello World 123"
        end
    end
    
    @testset "ungroup_text" begin
        @testset "Basic functionality" begin
            # Standard spaced groups
            @test ungroup_text("ABCDE FGHIJ") == "ABCDEFGHIJ"
            @test ungroup_text("THIS IS A TEST") == "THISISATEST"
            
            # Single group
            @test ungroup_text("ABCDE") == "ABCDE"
            
            # Empty string
            @test ungroup_text("") == ""
        end
        
        @testset "Different separators" begin
            # Multiple spaces
            @test ungroup_text("ABC  DEF   GHI") == "ABCDEFGHI"
            
            # Tabs
            @test ungroup_text("ABC\tDEF\tGHI") == "ABCDEFGHI"
            
            # Newlines
            @test ungroup_text("ABC\nDEF\nGHI") == "ABCDEFGHI"
            
            # Mixed separators
            @test ungroup_text("ABC DEF\tGHI\nJKL") == "ABCDEFGHIJKL"
            
            # Leading/trailing spaces
            @test ungroup_text(" ABC DEF ") == "ABCDEF"
        end
        
        @testset "Special cases" begin
            # Irregular grouping
            @test ungroup_text("AB CDE FGHI J") == "ABCDEFGHIJ"
            
            # Multiple consecutive separators
            @test ungroup_text("ABC      DEF") == "ABCDEF"
            
            # Only separators
            @test ungroup_text("   ") == ""
            
            # Mixed with non-alphanumeric (should preserve them)
            @test ungroup_text("ABC! DEF? GHI.") == "ABC!DEF?GHI."
        end
    end
    
    @testset "Roundtrip consistency" begin
        original_texts = [
            "THISISASECRETMESSAGE",
            "HELLO",
            "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
            "TEST123",
            "A"
        ]
        
        for text in original_texts
            # Test that ungrouping grouped text returns original
            grouped = group_text(text)
            @test ungroup_text(grouped) == text
            
            # Test with different block sizes
            for block_size in [2, 3, 4, 5]
                grouped = group_text(text, block_size=block_size)
                @test ungroup_text(grouped) == text
            end
            
            # Test with different separators
            for separator in [" ", "-", "|", "\n"]
                grouped = group_text(text, separator=separator)
                @test ungroup_text(grouped, separator=separator) == text
            end
        end
    end
end