# API Reference

## Modules

```@docs
ClassicCiphers.ClassicCiphers
ClassicCiphers.Alphabet
ClassicCiphers.Ciphers
ClassicCiphers.Traits
```

## Alphabet

```@docs
ClassicCiphers.Alphabet.AlphabetParameters
```

### Constants

```@docs
ClassicCiphers.Alphabet.UPPERCASE_LETTERS
ClassicCiphers.Alphabet.LOWERCASE_LETTERS
ClassicCiphers.Alphabet.DIGITS_LETTERS
```

## Abstract Types

```@docs
ClassicCiphers.AbstractCipher
ClassicCiphers.AbstractStreamCipherConfiguration
ClassicCiphers.Ciphers.AbstractCipherState
```

## Cipher state

```@docs
ClassicCiphers.Ciphers.State
ClassicCiphers.Ciphers.EmptyCipherState
ClassicCiphers.Ciphers.ValidCharCount
```

## Case Handling

```@docs
ClassicCiphers.Traits.InputCaseMode
ClassicCiphers.Traits.OutputCaseMode
ClassicCiphers.Traits.InputCaseHandler
ClassicCiphers.Traits.CaseHandler

ClassicCiphers.Traits.case_sensitive
ClassicCiphers.Traits.not_case_sensitive
ClassicCiphers.Traits.iscasesensitive

ClassicCiphers.Traits.preserve_case
ClassicCiphers.Traits.is_preserve

ClassicCiphers.Traits.lowercase_case
ClassicCiphers.Traits.is_lowercase

ClassicCiphers.Traits.uppercase_case
ClassicCiphers.Traits.is_uppercase

ClassicCiphers.Traits.cccase
ClassicCiphers.Traits.is_cccase

ClassicCiphers.Traits.default_case
ClassicCiphers.Traits.is_default

ClassicCiphers.Traits.apply_case
```

## Unknown Symbol Handling

```@docs
ClassicCiphers.Traits.UnknownSymbolHandlingTrait
ClassicCiphers.Traits.UnknownSymbolMode
ClassicCiphers.Traits.SymbolHandler

ClassicCiphers.Traits.ignore_symbol
ClassicCiphers.Traits.is_ignore

ClassicCiphers.Traits.remove_symbol
ClassicCiphers.Traits.is_remove

ClassicCiphers.Traits.replace_symbol
ClassicCiphers.Traits.is_replace

ClassicCiphers.Traits.transform_symbol
```

## Cipher Traits

```@docs
ClassicCiphers.Traits.CipherTrait
ClassicCiphers.Traits.CipherTypeTrait
ClassicCiphers.Traits.SubstitutionTrait
ClassicCiphers.Traits.ShiftSubstitution
```

## Handling Traits

```@docs
ClassicCiphers.Traits.InputCaseHandlingTrait
ClassicCiphers.Traits.OutputCaseHandlingTrait
```

## Core Functions

```@docs
ClassicCiphers.Ciphers.inv
ClassicCiphers.Ciphers.process_char!
ClassicCiphers.Ciphers.transform_index
```

## Stream API

`fit!`
`OnlineStatsBase._fit!`

```@docs
ClassicCiphers.Ciphers.AbstractStreamCipher
ClassicCiphers.Ciphers.connect!
ClassicCiphers.Ciphers.fit_listeners!
```

## Cipher specifics

### Substitution

```@docs
ClassicCiphers.Ciphers.SubstitutionCipher
```

### Caesar

```@docs
ClassicCiphers.Ciphers.CaesarCipher
```

### ROT13

```@docs
ClassicCiphers.Ciphers.ROT13Cipher
```

### Affine

```@docs
ClassicCiphers.Ciphers.AffineCipher
```

### XOR

```@docs
ClassicCiphers.Ciphers.XORCipher
```

### Vigenere

```@docs
ClassicCiphers.Ciphers.VigenereCipher
ClassicCiphers.Ciphers.get_shift
```

### Vernam

```@docs
ClassicCiphers.Ciphers.VernamCipher
```

## Index

```@index
```