"""
    InputCaseMode

Enumeration of input case handling modes.

# Values
- `NOT_CASE_SENSITIVE`: Treat upper/lowercase as same (default)
- `CASE_SENSITIVE`: Distinguish between upper/lowercase
"""
@enum InputCaseMode begin
    NOT_CASE_SENSITIVE     # Insensitive to case
    CASE_SENSITIVE         # Sensitivity to case
end

"""
    InputCaseHandlingTrait <: CipherTrait

Abstract type for traits that control how ciphers handle letter case in input text.
"""
abstract type InputCaseHandlingTrait <: CipherTrait end

"""
    InputCaseHandler{M} <: InputCaseHandlingTrait

Trait type for handling input case sensitivity.

# Type parameters
- `M`: Type of case mode (usually `InputCaseMode`)

# Fields
- `mode::M`: The case handling mode to use
"""
struct InputCaseHandler{M} <: InputCaseHandlingTrait
    mode::M
end

"""
    case_sensitive()

Create an `InputCaseHandler` that distinguishes between uppercase and lowercase letters.

# Returns
- `InputCaseHandler{InputCaseMode}`: Handler with `CASE_SENSITIVE` mode
"""
case_sensitive() = InputCaseHandler(CASE_SENSITIVE)

"""
    not_case_sensitive()

Create an `InputCaseHandler` that treats uppercase and lowercase letters as equivalent.

# Returns
- `InputCaseHandler{InputCaseMode}`: Handler with `NOT_CASE_SENSITIVE` mode

# See Also
- [`InputCaseMode`](@ref)
- [`case_sensitive`](@ref)
"""
not_case_sensitive() = InputCaseHandler(NOT_CASE_SENSITIVE)

"""
    iscasesensitive(handler::InputCaseHandler)

Check if an input case handler distinguishes between uppercase and lowercase letters.

# Arguments
- `handler::InputCaseHandler`: The case handler to check

# Returns
- `Bool`: `true` if handler is case sensitive, `false` otherwise

# See Also
- [`InputCaseMode`](@ref)
- [`case_sensitive`](@ref)
- [`not_case_sensitive`](@ref)
"""
iscasesensitive(handler::InputCaseHandler) = handler.mode == CASE_SENSITIVE
