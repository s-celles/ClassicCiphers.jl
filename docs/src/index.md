# ClassicCiphers.jl

A Julia package implementing classical cryptographic ciphers with configurable alphabet and case handling.

## Overview

ClassicCiphers.jl provides implementations of several classical ciphers:
- ROT13: A special case of Caesar cipher with shift=13
- Caesar cipher: Shifts each letter by a fixed amount
- Affine cipher: Combines multiplication and addition operations, using formula E(x) = (ax + b) mod m, where a and m are coprime
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

### String API

Lets demonstrates the string processing API for the ClassicCiphers package by showing examples of both the Caesar cipher and Vigenère cipher implementations.

```julia
using ClassicCiphers

# Create a Caesar cipher with default settings
cipher = CaesarCipher(shift=3)
plain_msg = "HELLO"
## Cipher message
ciphered_msg = cipher(plain_msg)  # Returns "KHOOR"
## Decipher message
recovered_msg = inv(cipher)(ciphered_msg)  # Returns "HELLO"

## Custom shift value
cipher = CaesarCipher(shift=5)
```

The first example shows the basic usage of the Caesar cipher, which is one of the simplest substitution ciphers. It creates a cipher with a shift of 3 positions (the traditional shift used by Julius Caesar). When applied to the plaintext `"HELLO"`, it shifts each letter forward by 3 positions in the alphabet, producing `"KHOOR"`. The inverse operation (`inv(cipher)`) creates a decryption cipher that shifts letters backward by 3 positions, recovering the original message.

The code then shows how to customize the Caesar cipher by using a different shift value (5 instead of 3), demonstrating the configurable nature of the implementation.

# Create a Vigenère cipher with custom case handling

```julia
params = AlphabetParameters(output_case_mode=PRESERVE_CASE)
cipher = VigenereCipher("SECRET", alphabet_params=params)
ciphered_msg = cipher("Hello World!")  # Returns "Zincs Pgvnu!"
recovered_msg = inv(cipher)(ciphered_msg)  # Returns "HELLO WORLD!"
```

This second example introduces the more complex Vigenère cipher, which uses a keyword (`"SECRET"` in this case) to create a polyalphabetic substitution. This example also demonstrates the case handling capabilities of the package through the `AlphabetParameters` configuration. By setting `output_case_mode=PRESERVE_CASE`, the cipher maintains the original case pattern of the input text - notice how `"Hello World!"` maintains its capitalization pattern in the encrypted output `"Zincs Pgvnu!"`.

Both examples showcase the consistent API design where:

1. Ciphers are created with their specific parameters
2. Encryption is performed by calling the cipher as a function
3. Decryption is achieved using the inv function to create a decryption cipher
4. Configuration options are passed through

### Stream API

The Stream API allows processing text one character at a time, making it ideal for:

- Large files that shouldn't be loaded entirely into memory
- Real-time encryption/decryption of streaming data
- Chaining multiple ciphers together in a processing pipeline

#### Basic Usage

```julia
# Create cipher and stream wrapper
cipher = CaesarCipher(shift=3)
stream_cipher = StreamCipher(cipher)

# Process individual characters
fit!(stream_cipher, 'H')
value(stream_cipher)  # Returns 'K'
```

#### Cipher Chaining

```julia
# Create encryption and decryption streams
cipher = CaesarCipher(shift=3)
decipher = inv(cipher)
stream_cipher = StreamCipher(cipher)
stream_decipher = StreamCipher(decipher)

# Connect them into a pipeline
connect!(stream_decipher, stream_cipher)
```

#### File Processing Example

```julia
# Process a file character by character
open("input.txt", "r") do input
   open("output.txt", "w") do output
      for c in readeach(io, Char)
         fit!(stream_decipher, c)
         write(out, value(stream_decipher)) 
      end
   end
end
```

The Stream API is built on Julia's [OnlineStats.jl](https://joshday.github.io/OnlineStats.jl) framework, providing:

- Memory efficiency through incremental processing
- Composability through cipher chaining
- Integration with Julia's IO system

This makes it particularly useful for processing large texts or implementing real-time encryption systems.

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
