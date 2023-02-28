from typing import Any, Optional

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
