"""
    OutputCaseMode

Enumeration for output case handling modes.
"""
@enum OutputCaseMode begin
    PRESERVE_CASE          # Keep original case from input
    LOWERCASE_CASE         # Convert to lowercase
    UPPERCASE_CASE         # Convert to uppercase
    CCCASE                 # crypto convention case ie lowercase for encryption, uppercase for decryption
    DEFAULT_CASE           # Use case from output alphabet
end

"""
    OutputCaseHandlingTrait <: CipherTrait

Abstract type for traits controlling output case handling.
"""
abstract type OutputCaseHandlingTrait <: CipherTrait end

"""
    CaseHandler{M} <: OutputCaseHandlingTrait

Concrete handler for output case transformations.

# Type parameters
- `M`: Type of case mode (usually [`OutputCaseMode`](@ref))
"""
struct CaseHandler{M} <: OutputCaseHandlingTrait
    mode::M
end

# Constructor functions

"""
Returns a `CaseHandler` instance configured to preserve the case of characters during cipher operations.

This means the output will maintain the same case (uppercase/lowercase) as the input text.

# Returns
- `CaseHandler`: A case handling object with PRESERVE_CASE behavior
"""
preserve_case() = CaseHandler(PRESERVE_CASE)


"""
    lowercase_case()

Create a `CaseHandler` instance that converts text to lowercase.

# Returns
- `CaseHandler`: A case handler that processes text to ensure all characters are lowercase.
"""
lowercase_case() = CaseHandler(LOWERCASE_CASE)

"""
    uppercase_case()

Create a `CaseHandler` instance set to handle uppercase text output.

# Returns
- `CaseHandler`: A case handler configured to convert output text to uppercase.
"""
uppercase_case() = CaseHandler(UPPERCASE_CASE)

"""
    cccase()

Create a `CaseHandler` instance with the standard common case format (`CCCASE`).

Returns a `CaseHandler` object that maintains the case format of cryptographic operations
using the common case convention.
"""
cccase() = CaseHandler(CCCASE)

"""
    default_case()

Create a `CaseHandler` with the default case settings.

Returns a `CaseHandler` initialized with `DEFAULT_CASE`, which determines the letter
case handling behavior for text processing operations.

# Returns
- `CaseHandler`: A new case handler instance with default case settings.
"""
default_case() = CaseHandler(DEFAULT_CASE)


# Helper functions

"""
    is_preserve(handler::CaseHandler) -> Bool

Check if a `CaseHandler` is configured to preserve the original case of characters.

Returns `true` if the handler's mode is set to preserve case, `false` otherwise.

# Arguments
- `handler::CaseHandler`: The case handler object to check
"""
is_preserve(handler::CaseHandler) = handler.mode == PRESERVE_CASE

"""
    is_lowercase(handler::CaseHandler) -> Bool

Check if the case mode of the handler is set to lowercase.

# Arguments
- `handler::CaseHandler`: The case handler to check

# Returns
`true` if the handler's mode is lowercase, `false` otherwise.
"""
is_lowercase(handler::CaseHandler) = handler.mode == LOWERCASE_CASE


"""
    is_uppercase(handler::CaseHandler) -> Bool

Check if the CaseHandler is set to uppercase mode.

Returns `true` if the handler's mode is set to `UPPERCASE_CASE`, `false` otherwise.

# Arguments
- `handler::CaseHandler`: The case handler to check

# Returns
- `Bool`: `true` if uppercase mode is set, `false` otherwise
"""
is_uppercase(handler::CaseHandler) = handler.mode == UPPERCASE_CASE

"""
    is_cccase(handler::CaseHandler) -> Bool

Check if the given case handler uses 'CCCASE' mode.

Returns `true` if the case handler's mode is set to `CCCASE`, `false` otherwise.

# Arguments
- `handler::CaseHandler`: The case handler object to check.
"""
is_cccase(handler::CaseHandler) = handler.mode == CCCASE

"""
    is_default(handler::CaseHandler) -> Bool

Check if a case handler is in default case mode.

# Arguments
- `handler::CaseHandler`: The case handler to check.

# Returns
- `Bool`: `true` if the case handler is in default case mode, `false` otherwise.
"""
is_default(handler::CaseHandler) = handler.mode == DEFAULT_CASE


# Apply case transformation based on mode

"""
    apply_case(handler::CaseHandler, plain_char::Char, base_char::Char, enc::Bool)

Applies the case transformation to a character based on the provided `CaseHandler`.

# Arguments
- `handler::CaseHandler`: The case handler that defines how the case transformation should be applied.
- `plain_char::Char`: The character to which the case transformation will be applied.
- `base_char::Char`: The base character used to determine the case transformation.
- `enc::Bool`: A boolean flag indicating whether the transformation is for encoding (`true`) or decoding (`false`).

# Returns
- `Char`: The character after applying the case transformation.
"""
function apply_case(handler::CaseHandler, plain_char::Char, base_char::Char, enc::Bool)
    if is_preserve(handler)
        isuppercase(plain_char) ? uppercase(base_char) : lowercase(base_char)
    elseif is_lowercase(handler)
        lowercase(base_char)
    elseif is_uppercase(handler)
        uppercase(base_char)
    elseif is_cccase(handler)
        enc ? lowercase(base_char) : uppercase(base_char)
    else # DEFAULT_CASE
        base_char
    end
end
