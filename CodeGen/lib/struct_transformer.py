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
            t.name: t for t in (self.enums + structs)
        }

        # TODO: Correctly create OptionSet types for enums with `Flags` variant
        # For now we just replace occurences of Flags with their underlying
        # enum
        for enum in self.enums:
            namespace[f"{enum.name}Flags"] = enum

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
        """A serious clean up is in order for this function. Once it has
        more functionality implemented it'll definitely get one.
        """

        return_type_replacements = {
            "UnsafeRawPointer?": "UnsafePointer<T>?",
            "UnsafeMutableRawPointer?": "UnsafeMutablePointer<T>?"
        }

        return_value_conversions = {
            "UnsafeRawPointer?": self.gen_raw_pointer_conversion,
            "UnsafeMutableRawPointer?": self.gen_raw_pointer_conversion
        }

        # TODO: Fix memory management so that all types can use ARC
        non_arc_types = ["WGPUCommandBuffer"]
        if method.name == "drop" and struct_name in non_arc_types:
            return

        writer.line("")

        return_type = return_type_replacements.get(
            method.return_type,
            method.return_type
        )

        # Generate function signature
        if method.name == "drop":
            # `drop` methods are put in `deinit` so that they are automatically
            # called when an instance has no strong references (Swift uses ARC)
            writer.line("deinit {")
        else:
            params = []
            for param in method.parameters:
                type_ = param.type_
                if type_ in namespace:
                    type_ = namespace[type_].swift_name()
                param_name = swiftify_identifier(param.name)
                params.append(f"{param_name}: {type_}")
            params_str = ", ".join(params)

            if return_type in return_type_replacements:
                return_type = return_type_replacements[return_type]

            type_parameters = "<T>" if "<T>" in return_type else ""

            is_void = return_type == "Void"
            return_clause = "" if is_void else f" -> {return_type}"

            writer.line(f"public func {method.name}{type_parameters}"
                        f"({params_str}){return_clause} {{")
        writer.indent()

        # Generate arguments
        args = ["c"]
        for param in method.parameters:
            param_name = swiftify_identifier(param.name)
            if param.type_ in namespace:
                args.append(namespace[param.type_].convert_to_c(param_name))
            else:
                args.append(param_name)
        args_str = ", ".join(args)

        call = f"{method.c_name}({args_str})"

        # Generate method body
        if method.return_type in return_value_conversions:
            convert = return_value_conversions[method.return_type]
            conversion_expr = convert("result")
            writer.block(f"""
            let result = {call}
            return {conversion_expr}
            """)
        else:
            writer.line(f"return {call}")

        writer.end_scope()

    def gen_raw_pointer_conversion(self, expr: str) -> str:
        return f"{expr}?.bindMemory(to: T.self, capacity: 1)"
