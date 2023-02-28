from typing import Optional
from pycparser import c_ast

from lib.writer import Writer
from lib.transformer import Transformer
from lib.utility import swiftify_identifier
from lib.intermediate_representation import (
    Struct,
    Method,
    FunctionSignature,
    Enum,
    TypeDecl
)


class StructTransformer(Transformer):
    """Transforms c struct declarations into Swift classes that act as
    convenient wrappers with the added benefit of automatic memory
    management.
    """

    def __init__(
            self,
            funcs: list[FunctionSignature],
            enums: list[Enum]) -> None:
        super().__init__()
        self.output_file = "Structs.swift"
        self.funcs = funcs
        self.enums = enums

    def visit(self, decl) -> Optional[Struct]:
        if type(decl) == c_ast.Typedef and decl.name.startswith("WGPU"):
            methods = []
            prefix = "wgpu" + decl.name[4:]

            # Search for functions that follow the instance method
            # pattern and have the current struct as their first
            # parameter. These will be turned into Swift instance
            # methods.
            for func in self.funcs:
                if func.name.startswith(prefix):
                    c_name = func.name
                    method_name = c_name[len(prefix):]
                    method_name = swiftify_identifier(method_name)

                    # Verify match
                    if func.parameters[0].type_ != decl.name:
                        continue

                    methods.append(Method(
                        method_name,
                        c_name,
                        func.parameters[1:],
                        func.return_type
                    ))

            return Struct(decl.name, methods)
        else:
            return None

    def gen(self, visitor_outputs: list[Struct], writer: Writer):
        structs_to_generate = ["WGPUBuffer", "WGPUCommandBuffer"]
        structs = list(filter(
            lambda x: x.name in structs_to_generate,
            visitor_outputs
        ))

        namespace: dict[str, TypeDecl] = {
            t.name: t for t in self.enums + structs
        }

        for struct in structs:
            writer.line("")

            # Give the type our own prefix to avoid naming clashes
            swift_name = struct.swift_name()

            # Structs are represented as classes for now so that
            # they can take advantage of automatic memory management.
            # In future, structs without a `drop` method should
            # probably just be represented as structs in Swift.
            writer.block(f"""
            public final class {swift_name} {{
                var c: {struct.name}

                init(_ c: {struct.name}) {{
                    self.c = c
                }}
            """)
            writer.indent()

            for method in struct.methods:
                self.gen_method(
                    method,
                    struct.name,
                    namespace,
                    writer
                )
            writer.end_scope()

    def gen_method(
            self,
            method: Method,
            struct_name: str,
            namespace: dict[str, TypeDecl],
            writer: Writer):
        if method.name == "drop" and struct_name == "WGPUCommandBuffer":
            # At the moment memory management is dodgy and
            # WGPUCommandBuffer shouldn't be auto-freed
            return

        writer.line("")

        conversions = {
            "UnsafePointer<CChar>?": ("String", lambda x: x)
        }

        params = []
        for param in method.parameters:
            type_ = param.type_
            if type_ in conversions:
                type_ = conversions[type_][0]
            params.append(f"{param.name}: {type_}")
        params_str = ", ".join(params)

        type_parameters = ""
        should_cast = False
        return_type = method.return_type
        if method.return_type.endswith("RawPointer?"):
            # Take a punt that functions that return raw
            # pointers are doing so because their return value
            # is meant to be cast to a user-specified type.
            type_parameters = "<T>"
            qualifier = "Mutable" if "Mutable" in method.return_type else ""
            return_type = f"Unsafe{qualifier}Pointer<T>?"
            should_cast = True

        # Generate function signature
        if method.name == "drop":
            # `drop` methods are put in `deinit` so that they
            # are automatically called when an instance has no
            # strong references (Swift uses ARC).
            writer.line("deinit {")
        else:
            writer.line(f"public func {method.name}{type_parameters}"
                        f"({params_str}) -> {return_type} {{")
        writer.indent()

        # Generate arguments
        args = ["c"]
        for param in method.parameters:
            if param.type_ in namespace:
                args.append(namespace[param.type_].convert_to_c(param.name))
            elif param.type_ in conversions:
                conversion = conversions[param.type_]
                args.append(conversion[1](param.name))
            else:
                args.append(param.name)
        args_str = ", ".join(args)

        call = f"{method.c_name}({args_str})"

        # Generate method body
        if should_cast:
            writer.block(f"""
            let result = {call}
            return result?.bindMemory(to: T.self, capacity: 1)
            """)
        else:
            writer.line(f"return {call}")

        writer.end_scope()
