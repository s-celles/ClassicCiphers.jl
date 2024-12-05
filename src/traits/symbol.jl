"""
    UnknownSymbolMode

Enumeration type defining possible modes for handling unknown symbols during
cipher operations.

This enum specifies how the cipher should behave when encountering symbols
that are not part of the defined cipher alphabet or symbol set.
"""
@enum UnknownSymbolMode begin
    IGNORE_SYMBOL  # Keep unknown symbols as-is
    REMOVE_SYMBOL  # Remove unknown symbols
    REPLACE_SYMBOL # Replace with ?
end

# Symbol handling trait
"""
    UnknownSymbolHandlingTrait <: CipherTrait

Abstract type representing the handling behavior for unknown symbols in cipher operations.

This trait defines how a cipher should process symbols that are not part of its defined alphabet
or symbol set. Concrete subtypes should specify specific handling strategies, such as ignoring,
throwing errors, or substituting with default values.

# Type Hierarchy
- Supertype: `CipherTrait`

# Extended By
Concrete implementations should extend this type to define specific handling behaviors.
"""
abstract type UnknownSymbolHandlingTrait <: CipherTrait end


"""
    SymbolHandler{M} <: UnknownSymbolHandlingTrait

A type that defines how unknown symbols should be handled during encryption/decryption operations.

The type parameter `M` specifies the mode of handling unknown symbols.

# Type Parameters
- `M`: The mode of handling unknown symbols (e.g., error, ignore, replace)

# Inheritance
Subtype of `UnknownSymbolHandlingTrait`
"""
struct SymbolHandler{M} <: UnknownSymbolHandlingTrait
    mode::M
    replace_symbol::Char
end

"""
    SymbolHandler(mode::UnknownSymbolMode, replace_symbol::Char='?')

Create a `SymbolHandler` instance with specified unknown symbol handling mode.

# Arguments
- `mode::UnknownSymbolMode`: Mode for handling unknown symbols (positional)
- `replace_symbol::Char=\'?\'`: Character used to replace unknown symbols (optional)
"""
SymbolHandler(mode::UnknownSymbolMode; replace_symbol = '?') =
    SymbolHandler(mode, replace_symbol)

# Constructor functions

"""
    ignore_symbol()

Return a `SymbolHandler` instance configured to ignore symbols during cipher operations.

The returned handler is initialized with the `IGNORE_SYMBOL` constant, which defines
the behavior of ignoring non-alphabetic characters in the text being processed.

# Returns
- `SymbolHandler`: A handler instance configured for symbol ignoring behavior
"""
ignore_symbol() = SymbolHandler(IGNORE_SYMBOL)

"""
    remove_symbol()

Create a `SymbolHandler` that removes symbols from text.

Returns a `SymbolHandler` instance configured to remove symbols during encryption or decryption operations.

# Returns
- `SymbolHandler`: A symbol handler configured to remove symbols from text
"""
remove_symbol() = SymbolHandler(REMOVE_SYMBOL)

"""
    replace_symbol()

Create a `SymbolHandler` with the `REPLACE_SYMBOL` strategy for handling symbols in text processing.

This function returns a `SymbolHandler` object configured to replace symbols according to the
predefined `REPLACE_SYMBOL` behavior.

# Returns
- `SymbolHandler`: A new symbol handler instance with replace strategy
"""
replace_symbol() = SymbolHandler(REPLACE_SYMBOL)

# Helper functions for checking mode

"""
    is_ignore(handler::SymbolHandler)

Returns `true` if the `SymbolHandler` is set to ignore symbols, `false` otherwise.

When a handler is in ignore mode, it will pass through unknown symbols without modification
during cipher operations.

# Arguments
- `handler::SymbolHandler`: The symbol handler to check.

# Returns
- `Bool`: `true` if the handler's mode is set to `IGNORE_SYMBOL`, `false` otherwise.
"""
is_ignore(handler::SymbolHandler) = handler.mode == IGNORE_SYMBOL

"""
    is_remove(handler::SymbolHandler) -> Bool

Check if the mode of the `SymbolHandler` is set to remove symbols.

# Returns
- `true` if the handler's mode is set to remove symbols
- `false` otherwise
"""
is_remove(handler::SymbolHandler) = handler.mode == REMOVE_SYMBOL

"""
    is_replace(handler::SymbolHandler) -> Bool

Check if the SymbolHandler's mode is set to replace symbols.

Returns `true` if the handler's mode is `REPLACE_SYMBOL`, `false` otherwise.
"""
is_replace(handler::SymbolHandler) = handler.mode == REPLACE_SYMBOL


"""
    transform_symbol(handler::SymbolHandler, plain_char::Char)

Transform a single plain character using the provided `SymbolHandler`.

# Arguments
- `handler::SymbolHandler`: The handler responsible for symbol transformation
- `plain_char::Char`: The character to be transformed

# Returns
A transformed character based on the handler's transformation rules.
"""
function transform_symbol(handler::SymbolHandler, plain_char::Char)
    if is_ignore(handler)
        return plain_char
    elseif is_remove(handler)
        return ""  # TODO REMOVE SYMBOL '' or "" (type inconsistency??)
    else # REPLACE_SYMBOL
        return handler.replace_symbol
    end
end
