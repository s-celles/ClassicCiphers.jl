# ClassicCiphers.jl

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/s-celles/ClassicCiphers.jl)
[![Build Status](https://github.com/s-celles/ClassicCiphers.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/s-celles/ClassicCiphers.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Dev Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://s-celles.github.io/ClassicCiphers.jl/dev/)
[![codecov](https://codecov.io/gh/s-celles/ClassicCiphers.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/s-celles/ClassicCiphers.jl)

A Julia package for classical cryptography ciphers with configurable alphabet, case handling, and unknown symbol management. Designed for CTF challenges, educational use, and cryptography exploration.

## Features

- **Substitution ciphers**: Caesar, ROT13, Affine, general Substitution
- **Polyalphabetic ciphers**: Vigenere, Vernam (One-Time Pad)
- **Stream ciphers**: XOR
- **Codes**: Morse
- **Formatting**: Text grouping into blocks
- **Dual API**: String-based and stream-based (via OnlineStats.jl)
- **Configurable**: Case sensitivity, case preservation, unknown symbol handling, custom alphabets

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/s-celles/ClassicCiphers.jl")
```

## Quick Start

```julia
using ClassicCiphers

# Caesar cipher
cipher = CaesarCipher(shift=3)
cipher("HELLO")          # "KHOOR"
inv(cipher)("KHOOR")     # "HELLO"

# Vigenere cipher with case preservation
params = AlphabetParameters(output_case_mode=PRESERVE_CASE)
cipher = VigenereCipher("SECRET", alphabet_params=params)
cipher("Hello World!")    # "Zincs Pgvnu!"

# Morse code
morse = MorseCode()
morse("HELLO")            # ".... . .-.. .-.. ---"

# Stream API
stream = StreamCipher(CaesarCipher(shift=3))
fit!(stream, 'H')
value(stream)             # 'K'
```

## Documentation

See the [full documentation](https://s-celles.github.io/ClassicCiphers.jl/dev/) for detailed usage, API reference, and examples.

## License

MIT
