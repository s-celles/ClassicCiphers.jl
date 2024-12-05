# ClassicCiphers.jl

A Julia package implementing classical cryptographic ciphers with configurable alphabet and case handling.

## Overview

ClassicCiphers.jl provides implementations of several classical ciphers:
- Caesar cipher: Shifts each letter by a fixed amount
- ROT13: A special case of Caesar cipher with shift=13
- Simple substitution cipher: Maps each letter to another using a provided mapping
- Vigenère cipher: Uses a keyword to determine shifting patterns
- Vernam cipher: Also known as the one-time pad

All ciphers support configurable:
- Case sensitivity
- Case preservation/conversion in output
- Unknown symbol handling
- Custom alphabets

## Installation

```julia
using Pkg
Pkg.add("ClassicCiphers")
```

## Quick Start

```julia
using ClassicCiphers

# Create a Caesar cipher with default settings
caesar = CaesarCipher(shift=3)
encrypted = caesar("HELLO")  # Returns "KHOOR"
decrypted = inv(caesar)(encrypted)  # Returns "HELLO"

# Create a Vigenère cipher with custom case handling
params = AlphabetParameters(output_case_mode=PRESERVE_CASE)
vigenere = VigenereCipher("SECRET", alphabet_params=params)
encrypted = vigenere("Hello World!")  # Returns "Zincs Pgvnu!"
decrypted = inv(vigenere)(encrypted)  # Returns "HELLO WORLD!"
```

## Core Types

### AlphabetParameters

Controls how the cipher handles alphabets and character transformations.

```julia
struct AlphabetParameters{CASE_SENSITIVITY, CASE_MEMORIZATION, UNKNOWN_SYMBOL_HANDLING}
    alphabet
    case_sensitivity::CASE_SENSITIVITY
    case_memorization::CASE_MEMORIZATION
    unknown_symbol_handling::UNKNOWN_SYMBOL_HANDLING
end
```

Parameters:
- `alphabet`: Set of valid characters (default: A-Z)
- `case_sensitivity`: Whether to distinguish between upper/lowercase
- `case_memorization`: How to handle case in output
- `unknown_symbol_handling`: How to handle characters not in alphabet

### Case Handling Options

Input case sensitivity:
- `NOT_CASE_SENSITIVE`: Treat upper/lowercase as same (default)
- `CASE_SENSITIVE`: Distinguish between upper/lowercase

Output case modes:
- `PRESERVE_CASE`: Keep original case from input
- `LOWERCASE_CASE`: Convert all to lowercase
- `UPPERCASE_CASE`: Convert all to uppercase
- `CCCASE`: Crypto convention case (lowercase for encryption, uppercase for decryption)
- `DEFAULT_CASE`: Use case from output alphabet (default)

Unknown symbol modes:
- `IGNORE_SYMBOL`: Keep unknown symbols as-is (default)
- `REMOVE_SYMBOL`: Remove unknown symbols
- `REPLACE_SYMBOL`: Replace with '?'

## Cipher Implementations

### CaesarCipher

Classic shift cipher that moves each letter a fixed number of positions.

```julia
# Basic usage
cipher = CaesarCipher(shift=3)
cipher("HELLO")  # Returns "KHOOR"

# With custom alphabet parameters
params = AlphabetParameters(case_sensitive=true)
cipher = CaesarCipher(shift=5, alphabet_params=params)
```

### ROT13Cipher

Special case of Caesar cipher with fixed shift of 13, making it self-inverse.

```julia
cipher = ROT13Cipher()
encrypted = cipher("HELLO")  # Returns "URYYB"
decrypted = cipher(encrypted)  # Returns "HELLO"
```

### SubstitutionCipher

Maps each character to another using a provided dictionary.

```julia
mapping = Dict('A'=>'X', 'B'=>'Y', 'C'=>'Z')
cipher = SubstitutionCipher(mapping)
cipher("ABC")  # Returns "XYZ"
```

### VigenereCipher

Polyalphabetic substitution cipher using a keyword to determine shifts.

```julia
cipher = VigenereCipher("SECRET")
cipher("HELLO")  # Returns "ZINCS"

# With case preservation
params = AlphabetParameters(output_case_mode=PRESERVE_CASE)
cipher = VigenereCipher("SECRET", alphabet_params=params)
cipher("Hello")  # Returns "Zincs"
```

## Utility Functions

All ciphers support:

- `inv(cipher)`: Create inverse cipher for decryption
- String and character-level operations: `cipher("ABC")` or `cipher('A')`

## Best Practices

1. **Case Handling**: Consider your use case when configuring case sensitivity:
   - For maximum security: Use `CASE_SENSITIVE`
   - For traditional crypto: Use `CCCASE`
   - For user-friendly output: Use `PRESERVE_CASE`

2. **Unknown Symbols**: Choose appropriate handling:
   - For maximum compatibility: Use `IGNORE_SYMBOL`
   - For clean output: Use `REMOVE_SYMBOL`
   - For error detection: Use `REPLACE_SYMBOL`

3. **Custom Alphabets**: Ensure they:
   - Contain all required characters
   - Have unique characters (checked with warning)
   - Match your case sensitivity settings

## Examples

### Basic Encryption/Decryption

```julia
# Caesar cipher with default settings
caesar = CaesarCipher(shift=3)
message = "THE QUICK BROWN FOX"
encrypted = caesar(message)
decrypted = inv(caesar)(encrypted)
@assert decrypted == uppercase(message)

# Vigenère cipher with case preservation
params = AlphabetParameters(output_case_mode=PRESERVE_CASE)
vigenere = VigenereCipher("SECRET", alphabet_params=params)
message = "Hello World!"
encrypted = vigenere(message)
decrypted = inv(vigenere)(encrypted)
@assert decrypted == uppercase(message)
```

### Custom Alphabet

```julia
# Create custom alphabet with only uppercase letters A-M
params = AlphabetParameters(alphabet=collect('A':'M'))
cipher = CaesarCipher(shift=3, alphabet_params=params)

# Letters N-Z will be handled according to unknown_symbol_handling
```

### Case Sensitivity

```julia
# Case sensitive substitution
params = AlphabetParameters(case_sensitive=true)
mapping = Dict('A'=>'X', 'a'=>'x', 'B'=>'Y', 'b'=>'y')
cipher = SubstitutionCipher(mapping, alphabet_params=params)

cipher("AaBb")  # Returns "XxYy"
cipher("AABB")  # Returns "XXYY"
```

## Testing

The package includes comprehensive tests for all ciphers and configurations:

```julia
using Test
using ClassicCiphers

# Run all tests
@testset "ClassicCiphers.jl" begin
    include("test/runtests.jl")
end
```

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## License

This project is licensed under the MIT License.