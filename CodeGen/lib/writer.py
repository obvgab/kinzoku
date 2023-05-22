import inspect


class Writer:
    _buffer: str
    _indent_level: int
    _indent_str: str

    def __init__(self):
        self._buffer = ""
        self._indent_level = 0
        self._regenerate_indent_str()

    def write(self, s: str):
        self._buffer += s

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
