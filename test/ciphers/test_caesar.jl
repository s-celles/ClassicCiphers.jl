import ClassicCiphers.Ciphers: CaesarCipher
import ClassicCiphers.Alphabet: AlphabetParameters
import ClassicCiphers.Traits:
    NOT_CASE_SENSITIVE, CASE_SENSITIVE, DEFAULT_CASE, PRESERVE_CASE, IGNORE_SYMBOL
import ClassicCiphers.Ciphers: StreamCipher, fit!, value, connect!
import ClassicCiphers.Traits: iscasesensitive, default_case, ignore_symbol

#=
This test set is for testing the CaesarCipher implementation.
It is part of the test suite for the ClassicCiphers package.
The tests within this block will verify the correctness of the CaesarCipher functionality.
=#
@testset "CaesarCipher" begin

    @testset "AlphabetParameters" begin
        alphabet_params = AlphabetParameters()
        cipher = CaesarCipher(shift = 3, alphabet_params = alphabet_params)
        @test !iscasesensitive(cipher.alphabet_params.case_sensitivity)
        @test cipher.alphabet_params.case_memorization == default_case()
        @test cipher.alphabet_params.unknown_symbol_handling == ignore_symbol()
    end

    @testset "cipher / decipher" begin
        n = 1
        ap_kwargs = Dict(
            :case_sensitivity => NOT_CASE_SENSITIVE,
            :output_case_mode => DEFAULT_CASE,
            :unknown_symbol_handling => IGNORE_SYMBOL,
        )
        @testset "$(n)" begin
            alphabet_params = AlphabetParameters(; ap_kwargs...)
            cipher = CaesarCipher(shift = 3, alphabet_params = alphabet_params)

            p = "..."
            @test cipher(p) == "..."  # unknown symbols are ignored (not transformed)


            p = "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG. the quick brown fox jumps over the lazy dog."  # this is a pangram or holoalphabetic sentence
            c = cipher(p)
            @testset "cipher" begin
                @test c ==
                      "WKH TXLFN EURZQ IRA MXPSV RYHU WKH ODCB GRJ. WKH TXLFN EURZQ IRA MXPSV RYHU WKH ODCB GRJ."
            end
            @testset "decipher" begin
                decipher = inv(cipher)
                @test decipher(c) == uppercase(p)
            end
        end

        n += 1  # 2
        ap_kwargs = Dict(
            :case_sensitivity => CASE_SENSITIVE,
            :output_case_mode => DEFAULT_CASE,
            :unknown_symbol_handling => IGNORE_SYMBOL,
        )
        @testset "$(n)" begin
            alphabet_params = AlphabetParameters(; ap_kwargs...)
            @test alphabet_params.alphabet ==
                  Vector{Char}("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz")
            cipher = CaesarCipher(shift = 3, alphabet_params = alphabet_params)
            p = "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG. the quick brown fox jumps over the lazy dog."
            c = cipher(p)
            @testset "cipher" begin
                @test c ==
                      "WKH TXLFN EURZQ IRa MXPSV RYHU WKH ODcb GRJ. wkh txlfn eurzq irA mxpsv ryhu wkh odCB grj."
            end
            @testset "decipher" begin
                decipher = inv(cipher)
                @test decipher(c) == p
            end
        end

        n += 1  # 3
        ap_kwargs = Dict(
            :case_sensitivity => NOT_CASE_SENSITIVE,
            :output_case_mode => PRESERVE_CASE,
            :unknown_symbol_handling => IGNORE_SYMBOL,
        )
        @testset "$(n)" begin
            alphabet_params = AlphabetParameters(; ap_kwargs...)
            cipher = CaesarCipher(shift = 3, alphabet_params = alphabet_params)
            p = "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG. the quick brown fox jumps over the lazy dog."
            c = cipher(p)
            @testset "cipher" begin
                @test c ==
                      "WKH TXLFN EURZQ IRA MXPSV RYHU WKH ODCB GRJ. wkh txlfn eurzq ira mxpsv ryhu wkh odcb grj."
            end
            @testset "decipher" begin
                decipher = inv(cipher)
                @test decipher(c) == p
            end
        end

    end

    @testset "stream API" begin
        @testset "cipher" begin
            cipher = CaesarCipher(shift = 3)
            stream_cipher = StreamCipher(cipher)
            fit!(stream_cipher, 'T')
            @test value(stream_cipher) == 'W'
            fit!(stream_cipher, 'H')
            @test value(stream_cipher) == 'K'
            fit!(stream_cipher, 'E')
            @test value(stream_cipher) == 'H'
        end

        @testset "decipher" begin
            cipher = CaesarCipher(shift = 3)
            stream_decipher = StreamCipher(inv(cipher))
            fit!(stream_decipher, 'W')
            @test value(stream_decipher) == 'T'
            fit!(stream_decipher, 'K')
            @test value(stream_decipher) == 'H'
            fit!(stream_decipher, 'H')
            @test value(stream_decipher) == 'E'
        end

        @testset "chaining" begin
            cipher = CaesarCipher(shift = 3)
            decipher = inv(cipher)

            stream_cipher = StreamCipher(cipher)
            stream_decipher = StreamCipher(decipher)
            connect!(stream_decipher, stream_cipher)  # connect the two ciphers in a chain (cipher -> decipher)

            fit!(stream_cipher, 'T')
            @test value(stream_cipher) == 'W'
            @test value(stream_decipher) == 'T'

            fit!(stream_cipher, 'H')
            @test value(stream_cipher) == 'K'
            @test value(stream_decipher) == 'H'

            fit!(stream_cipher, 'E')
            @test value(stream_cipher) == 'H'
            @test value(stream_decipher) == 'E'
        end

        # @testset "file I/O" begin
        #     cipher = CaesarCipher()
        #     decipher = inv(cipher)
# 
        #     stream_cipher = StreamCipher(cipher)
        #     stream_decipher = StreamCipher(decipher)
        #     connect!(stream_decipher, stream_cipher)  # connect the two ciphers in a chain (cipher -> decipher)
# 
        #     # Test file I/O
        #     input_file = "test.txt"
        #     output_file = "test_encrypted.txt"
        #     decrypted_file = "test_decrypted.txt"
# 
        #     # Write test data to file
        #     open(input_file, "w") do io
        #         write(io, "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG. the quick brown fox jumps over the lazy dog.")
        #     end
# 
        #     # Encrypt file
        #     open(input_file, "r") do io
        #         open(output_file, "w") do out
        #             for c in io
        #                 fit!(stream_cipher, c)
        #                 write(out, value(stream_cipher))
        #             end
        #         end
        #     end
# 
        #     # Decrypt file
        #     open(output_file, "r") do io
        #         open(decrypted_file, "w") do out
        #             for c in io
        #                 fit!(stream_decipher, c)
        #                 write(out, value(stream_decipher))
        #             end
        #         end
        #     end
# 
        #     # Verify decrypted file
        #     open(decrypted_file, "r") do io
        #         @test read(io, String) == "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG. the quick brown fox jumps over the lazy dog."
        #     end
        # end

    end
end
