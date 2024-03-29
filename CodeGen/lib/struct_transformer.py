from typing import Optional
from pycparser import c_ast

from lib.writer import Writer
from lib.transformer import Transformer
from lib.utility import (
    swiftify_identifier,
    camel_case_to_words,
    c_type_to_swift_type
)

from lib.intermediate_representation import (
    Struct,
    Method,
    FunctionSignature,
    FunctionParameter,
    Enum,
    TypeDecl,
    Member
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

        # Only a select few structs currently have autogenerated wrappers
        # because the generator isn't sophisticated enough for most yet.
        self.structs_to_generate = [
            "WGPUBuffer",
            "WGPUVertexBufferLayout",
            "WGPUCommandBuffer",
            "WGPUVertexState",
            "WGPUConstantEntry"
        ]

        # A mapping used to replace certain return types.
        self.return_type_replacements = {
            "UnsafeRawPointer?": "UnsafePointer<T>?",
            "UnsafeMutableRawPointer?": "UnsafeMutablePointer<T>?"
        }

        # A mapping used to generate code that converts a return value
        # from the original type to the new return type (as defined by
        # `return_type_replacements`).
        self.return_value_conversions = {
            "UnsafeRawPointer?": self.gen_raw_pointer_conversion,
            "UnsafeMutableRawPointer?": self.gen_raw_pointer_conversion
        }

        # Default values to use for parameters based on their name. Has
        # precendence over `parameter_type_default_values`.
        self.parameter_name_default_values = {
            "userData": "nil",
            "offset": "0",
            "nextInChain": "nil"
        }

        # Default values to use for parameters based on their type.
        self.parameter_type_default_values = {
            "WGPUBufferMapCallback": "{ _, _ in }"
        }

    def visit(self, decl) -> Optional[Struct]:
        if type(decl) == c_ast.Typedef and decl.name.startswith("WGPU"):
            methods = []
            prefix = "wgpu" + decl.name[4:]

            members = []
            if type(decl.type.type) == c_ast.Struct:
                for member in decl.type.type.decls:
                    members.append(Member(
                        member.name,
                        c_type_to_swift_type(member.type)
                    ))

            # Search for functions that follow the instance method pattern
            # and have the current struct as their first parameter.
            for func in self.funcs:
                if func.name.startswith(prefix):
                    c_name = func.name
                    method_name = c_name[len(prefix):]
                    method_name = swiftify_identifier(method_name)

                    # Verify that the function is an instance method of the
                    # current struct.
                    if func.parameters[0].type_ != decl.name:
                        continue

                    methods.append(Method(
                        method_name,
                        c_name,
                        func.parameters[1:],
                        func.return_type
                    ))

            return Struct(decl.name, members, methods)
        else:
            return None

    def gen(self, visitor_outputs: list[Struct], writer: Writer):
        structs = list(filter(
            lambda x: x.name in self.structs_to_generate,
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

            # If a struct has a drop method, represent it as a class to
            # take advantage of ARC.
            type_of_type = "struct"
            for method in struct.methods:
                if method.name == "drop":
                    type_of_type = "final class"
                    break

            writer.block(f"""
            public {type_of_type} {swift_name} {{
                var c: {struct.name}

                init(_ c: {struct.name}) {{
                    self.c = c
                }}
            """)
            writer.indent()

            # Certain c structs don't have initializers (because they're
            # represented as opaque pointers by Swift), and the best way
            # of detecting these that I've found (haven't looked long)
            # is that they have no members.
            if len(struct.members) != 0:
                writer.line("")
                self.gen_init(struct, namespace, writer)

            for method in struct.methods:
                self.gen_method(
                    method,
                    struct.name,
                    namespace,
                    writer
                )

            writer.end_scope()

    def gen_init(
            self,
            struct: Struct,
            namespace: dict[str, TypeDecl],
            writer: Writer):
        """Generates an initializer for the given struct into the given writer
        """

        params_str = self.gen_params_str(
            "init",
            list(map(
                lambda x: FunctionParameter(x.name, x.type_),
                struct.members
            )),
            namespace
        )

        # TODO: Reuse args_str generation code from `gen_method`.
        args = []
        for member in struct.members:
            member_name = swiftify_identifier(member.name)

            value = member_name
            if member.type_ in namespace:
                # `gen_method` uses a generic method, but in inits c
                # seems to have stronger type-checking of enums.
                value = f"{member_name}.c"
            elif member.type_ == "String":
                # TODO: Figure out when `strdup` is necessary and check that
                # it isn't causing memory leaks.
                value = f"strdup({member.name})"

            args.append(f"{member.name}: {value}")
        args_str = ", ".join(args)

        writer.block(f"""
        public init({params_str}) {{
            self.c = {struct.name}({args_str})
        }}
        """)

    def gen_method(
            self,
            method: Method,
            struct_name: str,
            namespace: dict[str, TypeDecl],
            writer: Writer):
        """Generates the code for a struct's method into the given `Writer`.
        """

        # TODO: Fix memory management so that all types can use ARC
        non_arc_types = ["WGPUCommandBuffer"]
        if method.name == "drop" and struct_name in non_arc_types:
            return

        # Purely aesthetic
        writer.line("")

        # Generate function signature
        if method.name == "drop":
            # `drop` methods are put in `deinit` so that they are automatically
            # called when an instance has no strong references (Swift uses ARC)
            writer.line("deinit {")
        else:
            new_return_type = self.return_type_replacements.get(
                method.return_type,
                method.return_type
            )

            self.gen_method_signature(
                method,
                new_return_type,
                namespace,
                writer
            )
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
        if method.return_type in self.return_value_conversions:
            convert = self.return_value_conversions[method.return_type]
            conversion_expr = convert("result")
            writer.block(f"""
            let result = {call}
            return {conversion_expr}
            """)
        else:
            writer.line(f"return {call}")

        writer.end_scope()

    def gen_method_signature(
            self,
            method: Method,
            new_return_type: str,
            namespace: dict[str, TypeDecl],
            writer: Writer):
        """Generates the opening line of a method declaration.
        """

        # Generate parameters (labels, types, default values etc.)
        params_str = self.gen_params_str(
            method.name,
            method.parameters,
            namespace
        )

        # There is a return type conversion that requires a generic parameter
        # so we detect that and add one here.
        type_parameters = "<T>" if "<T>" in new_return_type else ""

        is_void = new_return_type == "Void"
        return_clause = "" if is_void else f" -> {new_return_type}"

        writer.line(
            f"public func {method.name}{type_parameters}"
            f"({params_str}){return_clause} {{"
        )

    def gen_params_str(
            self,
            method_name: str,
            parameters: list[FunctionParameter],
            namespace: dict[str, TypeDecl]) -> str:
        method_name_words = camel_case_to_words(method_name)

        params = []
        is_first = True
        for param in parameters:
            # Replace param type with Swift wrapper if one exists
            type_ = param.type_
            if type_ in namespace:
                type_ = namespace[type_].swift_name()

            param_name = swiftify_identifier(param.name)

            # Choose a sensible default value if the parameter has one.
            default_value = None
            if param_name in self.parameter_name_default_values:
                default_value = self.parameter_name_default_values[param_name]
            elif type_ in self.parameter_type_default_values:
                default_value = self.parameter_type_default_values[type_]
            default_value = f" = {default_value}" if default_value else ""

            # Follow the Swift convention of omitting parameter labels if
            # the last word of the method name matches the label.
            if is_first and param_name == method_name_words[-1]:
                param_name = f"_ {param_name}"
            is_first = False

            params.append(f"{param_name}: {type_}{default_value}")

        return ", ".join(params)

    def gen_raw_pointer_conversion(self, expr: str) -> str:
        return f"{expr}?.bindMemory(to: T.self, capacity: 1)"
