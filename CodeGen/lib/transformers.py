from typing import Any, Optional
from pycparser import c_ast

from lib.utility import (
    stringify,
    swiftify_identifier,
    c_type_to_swift_type
)
from lib.writer import Writer


class Transformer:
    """A transformer takes an AST as input and generates code into a
    writer. It is used to create various boilerplate code from the
    wgpu-native and WebGPU headers. Transformers should inherit from
    this interface and implement both `visit` and `gen` to be useful.
    """
    output_file: str
    prelude: Optional[str]

    def __init__(self) -> None:
        self.prelude = None

    def visit(self, decl) -> Optional[Any]:
        """Visits a top level AST node and outputs an implementation
        specific intermediate representation. Nodes can be skipped by
        returning `None`.
        """

        pass

    def gen(self, visitor_outputs: list[Any], writer: Writer):
        """Generates code into `writer` from the list of successful
        visit outputs.
        """

        pass


class FunctionTransformer(Transformer):
    """Transforms c function declarations into the Swift code used by
    Kinzoku to import wgpu-native's functions from a platform-specific
    wgpu-native prebuilt dynamic library. Kinzoku uses this method of
    interfacing with wgpu-native because Swift does not yet support
    binary dependencies on non-Apple platforms.
    """

    def __init__(self) -> None:
        super().__init__()
        self.output_file = "Functions.swift"
        self.prelude = "fileprivate let loader = Loader()\n"

    def visit(self, decl) -> Optional[Any]:
        if type(decl.type) == c_ast.FuncDecl:
            func_decl = decl.type

            swift_params = []
            for param in func_decl.args.params:
                param_type = c_type_to_swift_type(param.type)
                if param_type != "Void":
                    swift_params.append((param.name, param_type))

            swift_return = c_type_to_swift_type(func_decl.type)

            return decl.name, swift_params, swift_return
        else:
            return None

    def gen(self, visitor_outputs: list[Any], writer: Writer):
        for (name, params, return_type) in visitor_outputs:
            params = ", ".join([param[1] for param in params])
            writer.line(
                f'let {name}: @convention(c) ({params})'
                f'-> {return_type} = loader.load("{name}")'
            )


class EnumTransformer(Transformer):
    """Tranforms c enum declarations into the equivalent Swift code
    so that users can make use of Swift's exhaustive switching of
    enum cases etc.
    """
    def __init__(self) -> None:
        super().__init__()
        self.output_file = "Enums.swift"

    def visit(self, decl) -> Optional[Any]:
        if type(decl) == c_ast.Typedef and decl.name.startswith("WGPU"):
            if type(decl.type.type) == c_ast.Enum:

                # For now we assume that all enums have a raw type of `UInt32`.
                enum_raw_type = "UInt32"

                cases = []
                prefixLength = len(decl.name) + 1
                for enum_case in decl.type.type.values.enumerators:
                    # Remove prefix from enum case name and fix up the
                    # resulting identifier to use lower camel case and
                    # escape names that would clash with Swift keywords.
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
            # TODO: Fix enum generation for KZInstanceBackend (we have
            # to evaluate constants to obtain equivalent literals).
            if name == "WGPUInstanceBackend":
                continue

            writer.line("")

            # TODO: Swift recommends not prefixing type names (and instead
            # requiring users to disambiguate naming clashes with absolute
            # references). Maybe we should follow that.

            # Give the name our own prefix to avoid naming clashes with
            # WGPU.
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

            # For some weird reason, some cases have the same numeric
            # values. As a workaround we create a property that
            # essentially sets up any duplicates as aliases to the
            # case that occurred with the value first.
            for shadow_case, original_case in duplicates:
                writer.line("")
                writer.block(f"""
                public static var {shadow_case}: {swift_name} {{
                    return .{original_case}
                }}
                """)

            writer.line("")

            # Generate interface for switching between C and Swift
            # representations of the enum.
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
    """Transforms c struct declarations into Swift classes that act as
    convenient wrappers with the added benefit of automatic memory
    management.
    """

    def __init__(self, swift_funcs: list[Any]) -> None:
        super().__init__()
        self.output_file = "Structs.swift"
        self.swift_funcs = swift_funcs

    def visit(self, decl) -> Optional[Any]:
        if type(decl) == c_ast.Typedef and decl.name.startswith("WGPU"):
            methods = []
            prefix = "wgpu" + decl.name[4:]

            # Search for functions that follow the instance method
            # pattern and have the current struct as their first
            # parameter. These will be turned into Swift instance
            # methods.
            for func in self.swift_funcs:
                if func[0].startswith(prefix):
                    func_name, params, return_type = func
                    method_name = func_name[len(prefix):]
                    method_name = swiftify_identifier(method_name)
                    if params[0][1] != decl.name:
                        # Verify match
                        continue
                    methods.append((
                        method_name,
                        func_name,
                        params[1:],
                        return_type
                    ))

            return decl.name, methods
        else:
            return None

    def gen_method(
            self,
            struct_name: str,
            method_name: str,
            func_name: str,
            params: list[tuple[str, str]],
            return_type: str, writer: Writer):
        if method_name == "drop" and struct_name == "WGPUCommandBuffer":
            # At the moment memory management is dodgy and
            # WGPUCommandBuffer shouldn't be
            return

        writer.line("")

        params_str = ", ".join(
            [f"{name}: {param_type}" for (name, param_type) in params]
        )

        # The first argument (`self`) should be `self.c`
        # because we assume that all methods are instance
        # methods
        arg_names = ["c"] + [name for (name, _) in params]
        args = ", ".join(arg_names)

        type_parameters = ""
        should_cast = False
        if return_type == "UnsafeMutableRawPointer?":
            # Take a punt that functions that return raw
            # pointers are doing so because their return value
            # is meant to be cast to a user-specified type.
            type_parameters = "<T>"
            return_type = "UnsafeMutablePointer<T>?"
            should_cast = True

        if method_name == "drop":
            # `drop` methods are put in `deinit` so that they
            # are automatically called when an instance has no
            # strong references (Swift uses ARC).
            writer.line("deinit {")
        else:
            writer.line(f"public func {method_name}{type_parameters}"
                        f"({params_str}) -> {return_type} {{")
        writer.indent()

        if should_cast:
            writer.block(f"""
            let result = {func_name}({args})
            return result?.bindMemory(to: T.self, capacity: 1)
            """)
        else:
            writer.line(f"return {func_name}({args})")

        writer.end_scope()

    def gen(self, visitor_outputs: list[Any], writer: Writer):
        for name, methods in visitor_outputs:
            if name != "WGPUBuffer" and name != "WGPUCommandBuffer":
                continue

            writer.line("")

            # Give the type our own prefix to avoid naming clashes
            swift_name = "KZ" + name[4:]

            # Structs are represented as classes for now so that
            # they can take advantage of automatic memory management.
            # In future, structs without a `drop` method should
            # probably just be represented as structs in Swift.
            writer.block(f"""
            public final class {swift_name} {{
                var c: {name}

                init(_ c: {name}) {{
                    self.c = c
                }}
            """)
            writer.indent()

            for method_name, func_name, params, return_type in methods:
                self.gen_method(
                    name,
                    method_name,
                    func_name,
                    params,
                    return_type,
                    writer
                )
            writer.end_scope()
