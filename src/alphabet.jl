"""
    Alphabet

A module containing alphabet-related functionality for classic ciphers.

This module provides various utilities and constants for handling alphabets
in cryptographic operations, particularly for classic cipher implementations.
"""
module Alphabet

using ClassicCiphers.Traits:
    InputCaseHandlingTrait, OutputCaseHandlingTrait, UnknownSymbolHandlingTrait
using ClassicCiphers.Traits:
    CASE_SENSITIVE, NOT_CASE_SENSITIVE, DEFAULT_CASE, PRESERVE_CASE, IGNORE_SYMBOL
using ClassicCiphers.Traits: InputCaseHandler, CaseHandler, SymbolHandler

"""
    UPPERCASE_LETTERS

Standard uppercase Latin alphabet (A-Z).
"""
const UPPERCASE_LETTERS = collect('A':'Z')

"""
    LOWERCASE_LETTERS

Standard lowercase Latin alphabet (a-z).
"""
const LOWERCASE_LETTERS = collect('a':'z')

"""
    DIGITS_LETTERS

Numeric digits (0-9).
"""
const DIGITS_LETTERS = collect('0':'9')

"""
AlphabetParameters: Configuration for alphabet handling

Fields:
- alphabet: Set of valid characters
"""
struct AlphabetParameters{
    CASE_SENSITIVITY<:InputCaseHandlingTrait,
    CASE_MEMORIZATION<:OutputCaseHandlingTrait,
    UNKNOWN_SYMBOL_HANDLING<:UnknownSymbolHandlingTrait,
}
    alphabet::Any
    case_sensitivity::CASE_SENSITIVITY
    case_memorization::CASE_MEMORIZATION
    unknown_symbol_handling::UNKNOWN_SYMBOL_HANDLING
end

"""
Creates AlphabetParameters with default settings

Keywords:
- alphabet: Base alphabet (default: UPPERCASE_LETTERS)
- case_sensitive: Whether to distinguish case (default: false)
- output_contains_source_case: Whether to preserve input case (default: false)
"""
function AlphabetParameters(;
    alphabet = UPPERCASE_LETTERS,
    case_sensitivity = NOT_CASE_SENSITIVE,
    output_case_mode = DEFAULT_CASE,
    unknown_symbol_handling = IGNORE_SYMBOL,
)

    allunique(alphabet) || @warn "Letters in the collection are not unique"

    (case_sensitivity == CASE_SENSITIVE) &&
        (output_case_mode == PRESERVE_CASE) &&
        @error "Output contains source case is not needed when case sensitive is true"

    if case_sensitivity == CASE_SENSITIVE
        alphabet = vcat(alphabet, lowercase.(alphabet))
    end

    case_sensitivity = InputCaseHandler(case_sensitivity)
    case_handler = CaseHandler(output_case_mode)
    unknown_symbol_handler = SymbolHandler(unknown_symbol_handling)

    AlphabetParameters(alphabet, case_sensitivity, case_handler, unknown_symbol_handler)
end

end
