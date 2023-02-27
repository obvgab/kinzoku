import subprocess
import os

from pycparser import c_parser, c_ast

# Preprocess the header file as required by the parser
text = subprocess.check_output(["clang", "-E", "wgpu.h"]).decode("utf-8")
def condition(line: str) -> bool:
    return line.strip() != "typedef __builtin_va_list __darwin_va_list;"
lines = filter(condition, text.split("\n"))

# Parse the header
parser = c_parser.CParser()
ast = parser.parse("\n".join(lines), filename="wgpu.h")

# Generate internal function declarations
output_dir = "../Sources/Kinzoku/Generated"
os.makedirs(output_dir, exist_ok=True)
output_file = f"{output_dir}/Functions.swift"

class TypeException(Exception):
    def __init__(self, message):
        self.message = message

    def __repr__(self) -> str:
        return self.message

type_rewrites = {
    "void": "Void",
    "char": "CChar",
    "int": "Int32",
    "long": "Int64",
    "uint32_t": "UInt32",
    "uint64_t": "UInt64",
    "int32_t": "Int32",
    "int64_t": "Int64",
    "size_t": "Int", # TODO: Verify that this is correct on all platforms
    "_Bool": "Bool",
    "float": "Float",
    "UnsafeMutablePointer<Void>?": "UnsafeMutableRawPointer?"
}

def rewrite_type(name: str) -> str:
    if name in type_rewrites:
        return type_rewrites[name]
    else:
        return name

def type_to_swift_type(t) -> str:
    if type(t) == c_ast.TypeDecl:
        return rewrite_type(t.type.names[0])
    elif type(t) == c_ast.PtrDecl:
        inner = rewrite_type(t.type.type.names[0])
        return rewrite_type("UnsafeMutablePointer<" + inner + ">?")
    else:
        raise TypeException("Unable to convert C type to Swift Type:\n" + t)

swift_funcs = []
for decl in ast.ext:
    if type(decl.type) == c_ast.FuncDecl:
        func_decl = decl.type

        swift_params = []
        for param in func_decl.args.params:
            param_type = type_to_swift_type(param.type)
            if param_type != "Void":
                swift_params.append((param.name, param_type))

        swift_return = type_to_swift_type(func_decl.type)

        swift_funcs.append((decl.name, swift_params, swift_return))

lines = ["private let loader = Loader()"]
for (name, params, return_type) in swift_funcs:
    if name == "wgpuSurfaceGetCapabilities":
        # This function has a parameter of type WGPUSurfaceCapabilities (which Swift can't find, and
        # neither can I). Therefore we skip it.
        continue

    params = ", ".join(map(lambda x: x[1], params))
    line = f'let {name}: @convention(c) ({params}) -> {return_type} = loader.load("{name}")'
    lines.append(line)

with open(output_file, "w") as f:
    f.write("\n".join(lines))
