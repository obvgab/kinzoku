# Kinzoku CodeGen

A majority of Kinzoku is boilerplate code designed to create a more Swift-like API for wgpu-native.
This code is in theory relatively simple to generate from the official `webgpu.h` header. That's
the aim of this subproject.

## Requirements

- `clang`
- `python3` (tested with 3.11)
- `pycparser`

## Architecture

The code generator is made up of a parsing phase followed by multiple transformation phases which
each take the parsed AST and generate Swift code with a specific purpose. For example, the
`FunctionTransformer` extracts all relevant (`wgpu` prefixed) functions from the wgpu headers and
transforms the function signatures into Swift code that is used to dynamically import each of these
functions from a precompiled dynamic library (long story). Each transformer's output is outputted to
a separate file in `../Sources/Kinzoku/Generated/`.

### Transformers

Each transformer has a `visit` phase and a `gen` phase. The `visit` phase consists of visiting each
top-level declaration in the header's AST one by one and generating useful intermediate
representations of interesting declarations. The `gen` phase then takes the intermediate
representations and converts them into Swift code that is usually a wrapper of some sort for the
underlying C declarations.
