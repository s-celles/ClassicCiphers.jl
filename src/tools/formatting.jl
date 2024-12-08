module TextFormatting

"""
    group_text(text::AbstractString; block_size::Int=5, separator::String=" ") -> String

Format text into blocks of specified size, typically used for cipher text presentation.

# Arguments
- `text::AbstractString`: Text to be formatted
- `block_size::Int=5`: Number of characters per block (default: 5)
- `separator::String=" "`: String used to separate blocks (default: space)
- `clean_text::Bool=true`: Remove non-alphanumeric characters from text before grouping

# Examples
```julia
julia> group_text("THISISASECRETMESSAGE")
"THISI SASER CETME SSAGE"

julia> group_text("HELLO", block_size=2)
"HE LL O"
```
"""
function group_text(text::AbstractString; block_size::Int=5, separator::String=" ", clean_text=true)
    if clean_text
        # Remove existing spaces and non-alphanumeric characters
        text = replace(text, r"[^A-Za-z0-9]" => "")
    end
    
    # Split into blocks
    blocks = [text[i:min(i+block_size-1, end)] 
              for i in 1:block_size:length(text)]
    
    # Join blocks with separator
    return join(blocks, separator)
end

"""
    ungroup_text(text::AbstractString; separator=nothing) -> String

Remove grouping formatting from text by removing separators.

# Arguments
- `text::AbstractString`: Text to be formatted
- `separator`: String used to separate blocks (default: all non-alphanumeric characters)

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