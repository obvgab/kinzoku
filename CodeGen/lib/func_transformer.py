from typing import Optional
from pycparser import c_ast

from lib.writer import Writer
from lib.transformer import Transformer
from lib.utility import c_type_to_swift_type
from lib.intermediate_representation import (
    FunctionSignature,
    FunctionParameter
)


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

    def visit(self, decl) -> Optional[FunctionSignature]:
        if type(decl.type) == c_ast.FuncDecl:
            func_decl = decl.type

            swift_params = []
            for param in func_decl.args.params:
                param_type = c_type_to_swift_type(param.type)
                if param_type != "Void":
                    swift_params.append(FunctionParameter(
                        param.name,
                        param_type
                    ))

            swift_return = c_type_to_swift_type(func_decl.type)

            return FunctionSignature(
                decl.name,
                swift_params,
                swift_return
            )
        else:
            return None

    def gen(self, visitor_outputs: list[FunctionSignature], writer: Writer):
        for func in visitor_outputs:
            parameter_type_list = ", ".join([
                param.type_ for param in func.parameters
            ])
            writer.line(
                f'let {func.name}: @convention(c) ({parameter_type_list})'
                f' -> {func.return_type} = loader.load("{func.name}")'
            )
