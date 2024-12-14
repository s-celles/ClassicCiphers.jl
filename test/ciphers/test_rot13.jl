import ClassicCiphers.Ciphers: ROT13Cipher
import ClassicCiphers.Alphabet: AlphabetParameters
import ClassicCiphers.Ciphers: StreamCipher, connect!, fit!, value
import ClassicCiphers.Traits: NOT_CASE_SENSITIVE, DEFAULT_CASE, IGNORE_SYMBOL
#=
This test set is for testing the ROT13 cipher implementation.
The ROT13 cipher is a simple substitution cipher where each letter
of the alphabet is replaced by the letter 13 positions after it.
This test set ensures that the ROT13 cipher functions correctly.
=#

@testset "ROT13Cipher" begin
    n = 1
    ap_kwargs = Dict(
        :case_sensitivity => NOT_CASE_SENSITIVE,
        :output_case_mode => DEFAULT_CASE,
        :unknown_symbol_handling => IGNORE_SYMBOL,
    )
    @testset "$(n)" begin
        alphabet_params = AlphabetParameters(; ap_kwargs...)
        cipher = ROT13Cipher(alphabet_params = alphabet_params)
        plaintext = "THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG. the quick brown fox jumps over the lazy dog."
        ciphertext = cipher(plaintext)
        @testset "cipher" begin
            @test ciphertext ==
                  "GUR DHVPX OEBJA SBK WHZCF BIRE GUR YNML QBT. GUR DHVPX OEBJA SBK WHZCF BIRE GUR YNML QBT."
        end
        @testset "decipher" begin
            decipher = inv(cipher)
            @test decipher(ciphertext) == uppercase(plaintext)
        end
    end

    @testset "stream API" begin
        @testset "cipher" begin
            cipher = ROT13Cipher()
            stream_cipher = StreamCipher(cipher)
            fit!(stream_cipher, 'T')
            @test value(stream_cipher) == 'G'
            fit!(stream_cipher, 'H')
            @test value(stream_cipher) == 'U'
            fit!(stream_cipher, 'E')
            @test value(stream_cipher) == 'R'
        end

        @testset "decipher" begin
            cipher = ROT13Cipher()
            stream_decipher = StreamCipher(inv(cipher))
            fit!(stream_decipher, 'G')
            @test value(stream_decipher) == 'T'
            fit!(stream_decipher, 'U')
            @test value(stream_decipher) == 'H'
            fit!(stream_decipher, 'R')
            @test value(stream_decipher) == 'E'
        end

        @testset "chaining" begin
            cipher = ROT13Cipher()
            decipher = inv(cipher)

            stream_cipher = StreamCipher(cipher)
            stream_decipher = StreamCipher(decipher)
            connect!(stream_decipher, stream_cipher)  # connect the two ciphers in a chain (cipher -> decipher)

            fit!(stream_cipher, 'T')
            @test value(stream_cipher) == 'G'
            @test value(stream_decipher) == 'T'

            fit!(stream_cipher, 'H')
            @test value(stream_cipher) == 'U'
            @test value(stream_decipher) == 'H'

            fit!(stream_cipher, 'E')
            @test value(stream_cipher) == 'R'
            @test value(stream_decipher) == 'E'
        end
    end
end
