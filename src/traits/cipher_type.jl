# Traits for cipher characteristics


"""
    abstract type CipherTrait end

A base abstract type representing cipher traits in the ClassicCiphers package.

This type serves as the root of the cipher trait type hierarchy, allowing for
type-based dispatch and classification of different cipher algorithms and their
characteristics.

# Extended help
Subtypes of `CipherTrait` should represent specific properties or behaviors
of cipher algorithms, enabling type-based dispatch for encryption and decryption
operations.
"""
abstract type CipherTrait end

"""
An abstract type representing cipher categories.

`CipherTypeTrait` serves as a base type for traits that classify different types of ciphers.
This trait hierarchy is used for dispatch and categorization of cipher algorithms.
"""
abstract type CipherTypeTrait <: CipherTrait end

# Substitution types

"""
    SubstitutionTrait <: CipherTypeTrait

A trait type representing substitution ciphers.

This abstract type is used to classify ciphers that operate by substituting one character
for another according to a defined pattern or key. It is a subtype of `CipherTypeTrait`,
which is the base trait for all cipher type classifications.
"""
abstract type SubstitutionTrait <: CipherTypeTrait end
#struct MonoalphabeticSubstitution <: SubstitutionTrait end
#struct PolyalphabeticSubstitution <: SubstitutionTrait end
#struct PolygraphicSubstitution <: SubstitutionTrait end

"""
    ShiftSubstitution <: SubstitutionTrait

A trait type representing shift substitution ciphers.

Shift substitution is a type of substitution cipher where each letter in the plaintext 
is shifted a certain number of positions in the alphabet. The most famous example 
is the Caesar cipher, which uses a shift of 3.
"""
struct ShiftSubstitution <: SubstitutionTrait end

#substitution_trait(::AbstractCipher) = ShiftSubstitution()

# Transposition types
#abstract type TranspositionTrait <: CipherTypeTrait end
#struct RouteTransposition <: TranspositionTrait end
#struct ColumnarTransposition <: TranspositionTrait end

# Product types
#abstract type ProductTrait <: CipherTypeTrait end
#struct CompositeProduct <: ProductTrait end
#struct FractionatedProduct <: ProductTrait end

# Default trait behaviors
#cipher_type_trait(::AbstractCipher) = MonoalphabeticSubstitution()
