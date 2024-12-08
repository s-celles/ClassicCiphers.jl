module TextFormatting

"""
    group_text(text::AbstractString; block_size::Int=5, separator::String=" ") -> String

Format text into blocks of specified size, typically used for cipher text presentation.

# Arguments
- `text::AbstractString`: Text to be formatted
- `block_size::Int=5`: Number of characters per block (default: 5)
- `separator::String=" "`: String used to separate blocks (default: space)

# Examples
```julia
julia> group_text("THISISASECRETMESSAGE")
"THISI SASER CETME SSAGE"

julia> group_text("HELLO", block_size=2)
"HE LL O"
```
"""
function group_text(text::AbstractString; block_size::Int=5, separator::String=" ")
    # Remove existing spaces and non-alphanumeric characters
    cleaned_text = replace(text, r"[^A-Za-z0-9]" => "")
    
    # Split into blocks
    blocks = [cleaned_text[i:min(i+block_size-1, end)] 
              for i in 1:block_size:length(cleaned_text)]
    
    # Join blocks with separator
    return join(blocks, separator)
end

"""
    ungroup_text(text::AbstractString) -> String

Remove grouping formatting from text by removing separators.

# Example
```julia
julia> ungroup_text("HELLO WORLD")
"HELLOWORLD"
```
"""
function ungroup_text(text::AbstractString; separator=nothing)
    if separator === nothing
        # Remove all non-alphanumeric characters
        replace(text, r"\s+" => "")
    else
        # Remove specified separator
        return replace(text, separator => "")
    end
end

end