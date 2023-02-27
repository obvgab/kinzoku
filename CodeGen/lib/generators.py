import inspect

from typing import Any, Optional
from lib.utility import stringify, swiftify_identifier
from pycparser import c_ast

type_rewrites = {
    "void": "Void",
    "char": "CChar",
    "int": "Int32",
    "long": "Int64",
    "uint32_t": "UInt32",
    "uint64_t": "UInt64",
    "int32_t": "Int32",
    "int64_t": "Int64",
    "size_t": "Int",
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
        raise Exception("Unable to convert C type to Swift Type: " + t)

class Writer:
    _buffer: str
    _indent_level: int
    _indent_str: str

    def __init__(self):
        self._buffer = ""
        self._indent_level = 0
        self._regenerate_indent_str()

    def line(self, line: str):
        if line == "":
            # Avoid trailing spaces caused by indenting an empty line
            self._buffer += "\n"
            return
        self._buffer += self._indent_str + line + "\n"

    def block(self, block: str):
        block = inspect.cleandoc(block)
        lines = block.split("\n")
        for i, line in enumerate(lines):
            if line != "":
                lines[i] = self._indent_str + line

        self._buffer += "\n".join(lines) + "\n"

    def indent(self):
        self._indent_level += 1
        self._regenerate_indent_str()

    def outdent(self):
        self._indent_level -= 1
        self._regenerate_indent_str()

    def end_scope(self):
        self.outdent()
        self.line("}")

    def _regenerate_indent_str(self):
        self._indent_str = " " * self._indent_level * 4

    def finish(self) -> str:
        return self._buffer

class Transformer:
    output_file: str
    prelude: Optional[str]

    def __init__(self) -> None:
        self.prelude = None

    def visit(self, decl) -> Optional[Any]:
        pass

    def gen(self, visitor_outputs: list[Any], writer: Writer):
        pass

class FunctionTransformer(Transformer):
    def __init__(self) -> None:
        super().__init__()
        self.output_file = "Functions.swift"
        self.prelude = "fileprivate let loader = Loader()\n"

    def visit(self, decl) -> Optional[Any]:
        if decl.name == "wgpuSurfaceGetCapabilities":
            # This function has a parameter of type WGPUSurfaceCapabilities
            # (which Swift can't find, and neither can I). Therefore
            # we skip it.
            return None
        elif type(decl.type) == c_ast.FuncDecl:
            func_decl = decl.type

            swift_params = []
            for param in func_decl.args.params:
                param_type = type_to_swift_type(param.type)
                if param_type != "Void":
                    swift_params.append((param.name, param_type))

            swift_return = type_to_swift_type(func_decl.type)

            return decl.name, swift_params, swift_return

    def gen(self, visitor_outputs: list[Any], writer: Writer):
        for (name, params, return_type) in visitor_outputs:
            params = ", ".join([param[1] for param in params])
            writer.line(f'let {name}: @convention(c) ({params}) -> {return_type} = loader.load("{name}")')

class EnumTransformer(Transformer):
    def __init__(self) -> None:
        super().__init__()
        self.output_file = "Enums.swift"

    def visit(self, decl) -> Optional[Any]:
        if decl.name == "WGPUInstanceBackend":
            return None
        elif type(decl) == c_ast.Typedef and decl.name.startswith("WGPU"):
            if type(decl.type.type) == c_ast.Enum:
                cases = []
                enum_raw_type = "UInt32"
                prefixLength = len(decl.name) + 1
                for enum_case in decl.type.type.values.enumerators:
                    case_name = enum_case.name[prefixLength:]
                    case_name = swiftify_identifier(case_name)

                    value = stringify(enum_case.value)
                    cases.append((case_name, value))
                return decl.name, enum_raw_type, cases
            else:
                return None
        else:
            return None

    def gen(self, visitor_outputs: list[Any], writer: Writer):
        for name, raw_type, cases in visitor_outputs:
            writer.line("")

            swift_name = "KZ" + name[4:]

            writer.line(f"public enum {swift_name}: {raw_type} {{")
            writer.indent()

            seen_values: dict[str, str] = {}
            duplicates: list[tuple[str, str]] = []
            for case_name, value in cases:
                if value in seen_values:
                    original_case = seen_values[value]
                    duplicates.append((case_name, original_case))
                    continue
                seen_values[value] = case_name
                writer.line(f"case {case_name} = {value}")

            for shadow_case, original_case in duplicates:
                writer.line("")
                writer.block(f"""
                var {shadow_case}: {swift_name} {{
                    return .{original_case}
                }}
                """)

            writer.line("")

            writer.block(f"""
            var c: {name} {{
                return {name}(rawValue: rawValue)
            }}

            init(_ c: {name}) {{
                 self = {swift_name}(rawValue: c.rawValue)!
            }}
            """)
            writer.end_scope()

class StructTransformer(Transformer):
    def __init__(self, swift_funcs: list[Any]) -> None:
        super().__init__()
        self.output_file = "Structs.swift"
        self.swift_funcs = swift_funcs

    def visit(self, decl) -> Optional[Any]:
        if type(decl) == c_ast.Typedef and decl.name.startswith("WGPU"):
            if decl.name == "WGPUInstanceBackend":
                return None

            methods = []
            prefix = "wgpu" + decl.name[4:]
            for func in self.swift_funcs:
                if func[0].startswith(prefix):
                    func_name, params, return_type = func
                    method_name = func_name[len(prefix):]
                    method_name = swiftify_identifier(method_name)
                    if params[0][1] != decl.name:
                        # Verify match
                        continue
                    methods.append((method_name, func_name, params[1:], return_type))

            return decl.name, methods
        else:
            return None

    def gen(self, visitor_outputs: list[Any], writer: Writer):
        for name, methods in visitor_outputs:
            if name != "WGPUBuffer" and name != "WGPUCommandBuffer":
                continue

            writer.line("")

            swift_name = "KZ" + name[4:]
            writer.block(f"""
            public final class {swift_name} {{
                var c: {name}

                init(_ c: {name}) {{
                    self.c = c
                }}
            """)
            writer.indent()

            for method_name, func_name, params, return_type in methods:
                if method_name == "drop" and name == "WGPUCommandBuffer":
                    # At the moment memory management is dodgy and WGPUCommandBuffer shouldn't be
                    # auto-dropped
                    continue

                writer.line("")

                params_str = ", ".join(f"{name}: {param_type}" for (name, param_type) in params)

                arg_names = ["c"] + [name for (name, _) in params]
                args = ", ".join(arg_names)

                type_parameters = ""
                should_cast = False
                if return_type == "UnsafeMutableRawPointer?":
                    type_parameters = "<T>"
                    return_type = "UnsafeMutablePointer<T>?"
                    should_cast = True

                if method_name == "drop":
                    writer.line("deinit {")
                else:
                    writer.line(f"public func {method_name}{type_parameters}({params_str}) -> {return_type} {{")
                writer.indent()

                if should_cast:
                    writer.block(f"""
                    let result = {func_name}({args})
                    return result?.bindMemory(to: T.self, capacity: 1)
                    """)
                else:
                    writer.line(f"return {func_name}({args})")

                writer.end_scope()
            writer.end_scope()
