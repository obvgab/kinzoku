from typing import Optional
from pycparser import c_ast

from lib.writer import Writer
from lib.transformer import Transformer
from lib.utility import swiftify_identifier, stringify
from lib.intermediate_representation import Enum, EnumCase


class EnumTransformer(Transformer):
    """Tranforms c enum declarations into the equivalent Swift code
    so that users can make use of Swift's exhaustive switching of
    enum cases etc.
    """
    def __init__(self) -> None:
        super().__init__()
        self.output_file = "Enums.swift"

    def visit(self, decl) -> Optional[Enum]:
        if type(decl) == c_ast.Typedef and decl.name.startswith("WGPU"):
            if type(decl.type.type) == c_ast.Enum:
                cases = []
                prefix_length = len(decl.name) + 1
                for enum_case in decl.type.type.values.enumerators:
                    # Remove prefix from enum case name and fix up the
                    # resulting identifier to use lower camel case and
                    # escape names that would clash with Swift keywords.
                    case_name = enum_case.name[prefix_length:]
                    case_name = swiftify_identifier(case_name)

                    value = stringify(enum_case.value)
                    cases.append(EnumCase(case_name, value))

                # For now we assume that all enums have a raw type of `UInt32`.
                return Enum(decl.name, "UInt32", cases)
            else:
                return None
        else:
            return None

    def gen(self, visitor_outputs: list[Enum], writer: Writer):
        for enum in visitor_outputs:
            # TODO: Fix enum generation for WGPUInstanceBackend (we have
            # to evaluate constants to obtain equivalent literals).
            if enum.name == "WGPUInstanceBackend":
                continue

            writer.line("")

            # TODO: Swift recommends not prefixing type names (and instead
            # requiring users to disambiguate naming clashes with absolute
            # references). Maybe we should follow that.

            swift_name = enum.swift_name()

            writer.line(f"public enum {swift_name}: {enum.raw_type} {{")
            writer.indent()

            seen_values: dict[str, str] = {}
            duplicates: list[tuple[str, str]] = []
            for case_ in enum.cases:
                if case_.value in seen_values:
                    original_case = seen_values[case_.value]
                    duplicates.append((case_.name, original_case))
                    continue
                seen_values[case_.value] = case_.name
                writer.line(f"case {case_.name} = {case_.value}")

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
            var c: {enum.name} {{
                return {enum.name}(rawValue: rawValue)
            }}

            init(_ c: {enum.name}) {{
                 self = {swift_name}(rawValue: c.rawValue)!
            }}
            """)
            writer.end_scope()
