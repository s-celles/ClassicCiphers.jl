"""
    MorseCode{ENC} <: AbstractStreamCipherConfiguration{ENC}

Implementation of the Morse code that converts between alphanumeric text and Morse code.
Uses "/" as a word separator and " " between letters.

# Type parameters
- `ENC::Bool`: true for encoding to Morse, false for decoding from Morse

# ToDo
- Add support for additional Morse code types
  - International Morse code ITU-R M.1677-1
  - American Morse code
  - Continental Morse code
  - Navy Morse code
  - Tap code
"""
struct MorseCode{ENC} <: AbstractStreamCipherConfiguration{ENC}
    # Morse code mappings
    to_morse::OrderedDict{Char,String}
    from_morse::Dict{String,Char}
    
    function MorseCode{ENC}() where {ENC}
        to_morse = OrderedDict{Char,String}(
            'A' => ".-", 'B' => "-...", 'C' => "-.-.", 'D' => "-..",
            'E' => ".", 'F' => "..-.", 'G' => "--.", 'H' => "....",
            'I' => "..", 'J' => ".---", 'K' => "-.-", 'L' => ".-..", 
            'M' => "--", 'N' => "-.", 'O' => "---", 'P' => ".--.",
            'Q' => "--.-", 'R' => ".-.", 'S' => "...", 'T' => "-",
            'U' => "..-", 'V' => "...-", 'W' => ".--", 'X' => "-..-",
            'Y' => "-.--", 'Z' => "--..", '0' => "-----", '1' => ".----",
            '2' => "..---", '3' => "...--", '4' => "....-", '5' => ".....",
            '6' => "-....", '7' => "--...", '8' => "---..", '9' => "----."
        )
        
        # Create reverse mapping for decoding
        from_morse = Dict(value => key for (key, value) in to_morse)
        
        new{ENC}(to_morse, from_morse)
    end
end

"""
    MorseCode()

Construct a Morse code encoder/decoder.

# Examples
```julia
# Create Morse code handler
morse = MorseCode()
```
"""
MorseCode() = MorseCode{true}()

"""
    State(morse::MorseCode)

Create initial state for Morse code operations.
"""
function State(morse::MorseCode)
    ValidCharCount()
end

"""
    process_char!(state::ValidCharCount, morse::MorseCode{true}, input_char::Char)

Process a single character for encoding to Morse code.
Handles word separation with "/" and letter separation with spaces.
"""
function process_char!(
    state::ValidCharCount,
    morse::MorseCode{true},
    input_char::Char
)
    state.valid_char_count += 1
    fixed_char = uppercase(input_char)
    
    if fixed_char == ' '
        return "/ "
    elseif haskey(morse.to_morse, fixed_char)
        morse_code = morse.to_morse[fixed_char]
        return morse_code * " "
    else
        # Handle unknown symbols by ignoring them
        return ""
    end
end

"""
    process_morse!(state::ValidCharCount, morse::MorseCode{false}, morse_code::AbstractString)

Process a Morse code string for decoding to alphanumeric text.
Handles both "/" word separators and space letter separators.
"""
function process_morse!(
    state::ValidCharCount,
    morse::MorseCode{false},
    morse_code::AbstractString
)
    state.valid_char_count += 1
    # Split into words first
    words = split(rstrip(morse_code), "/")
    result = String[]
    
    for word in words
        word = strip(word)
        if isempty(word)
            continue
        end
        
        # Split word into letters
        letters = String[]
        for symbol in split(word)
            if isempty(symbol)
                continue
            end
            
            if haskey(morse.from_morse, symbol)
                push!(letters, string(morse.from_morse[symbol]))
            else
                # Handle unknown symbols as empty string
                continue
            end
        end
        
        push!(result, join(letters))
    end
    
    return join(result, " ")
end

"""
    (morse::MorseCode{true})(plaintext::AbstractString)

Encode text to Morse code, using "/" as word separator and spaces between letters.

# Arguments
- `plaintext::AbstractString`: Text to encode

# Returns
- `String`: Morse code representation
"""
function (morse::MorseCode{true})(plaintext::AbstractString)
    isempty(plaintext) && return ""
    state = State(morse)
    result = ""
    for c in plaintext
        result *= process_char!(state, morse, c)
    end
    return rstrip(result)
end

"""
    (morse::MorseCode{false})(codetext::AbstractString)

Decode Morse code to text.

# Arguments
- `codetext::AbstractString`: Morse code to decode, using "/" as word separator

# Returns
- `String`: Decoded text in uppercase
"""
function (morse::MorseCode{false})(codetext::AbstractString)
    isempty(codetext) && return ""
    state = State(morse)
    return process_morse!(state, morse, codetext)
end

"""
    inv(morse::MorseCode{ENC}) where {ENC}

Create an inverse Morse code handler that decodes messages encoded with the original handler.

# Arguments
- `morse::MorseCode{ENC}`: The Morse code handler to invert

# Returns
- `MorseCode{!ENC}`: A new Morse code handler for the opposite operation

# Examples
```julia
# Create encoder and decoder
morse = MorseCode()
demorse = inv(morse)

# They perform opposite operations
plaintext  = "HELLO WORLD"
codetext = morse(plaintext)     # ".... . .-.. .-.. --- / .-- --- .-. .-.. -.."
recovered_plaintext = demorse(codetext)   # "HELLO WORLD"
```
"""
function inv(morse::MorseCode{ENC}) where {ENC}
    MorseCode{!ENC}()
end