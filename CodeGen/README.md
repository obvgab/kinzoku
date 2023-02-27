# Kinzoku CodeGen

A majority of Kinzoku is boilerplate code designed to create a more Swift-like API for wgpu-native.
This code is in theory relatively simple to generate from the official `webgpu.h` header. That's
the aim of this subproject.

## Requirements

- `clang`
- `python3` (tested with 3.11)
- `pycparser`
