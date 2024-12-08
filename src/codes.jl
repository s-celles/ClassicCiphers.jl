module Codes

export inv
import Base: inv

using DataStructures: OrderedDict
using ClassicCiphers: AbstractStreamCipherConfiguration
using ClassicCiphers.Ciphers: ValidCharCount

include("codes/morse.jl")

end
