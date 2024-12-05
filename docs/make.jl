using Documenter
using ClassicCiphers

makedocs(
    sitename = "ClassicCiphers.jl",
    format = Documenter.HTML(),
    modules = [ClassicCiphers],
    warnonly = [:missing_docs],
    pages = [
        "Home" => "index.md",
        #"Ciphers" => [
        #    "Caesar Cipher" => "ciphers/caesar.md",
        #    "ROT13 Cipher" => "ciphers/rot13.md",
        #    "Substitution Cipher" => "ciphers/substitution.md",
        #    "Vigenère Cipher" => "ciphers/vigenere.md",
        #    "Vernam Cipher" => "ciphers/vernam.md"
        #],
        "API Reference" => "api.md",
    ],
)

# Documenter can also automatically deploy documentation to gh-pages.
# See "Hosting Documentation" and deploydocs() in the Documenter manual
# for more information.
#=deploydocs(
    repo = "<repository url>"
)=#
