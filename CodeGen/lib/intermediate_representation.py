from dataclasses import dataclass


@dataclass()
class FunctionParameter:
    name: str
    type_: str


@dataclass()
class FunctionSignature:
    name: str
    parameters: list[FunctionParameter]
    return_type: str


class TypeDecl:
    """Inherited from by Enum and Struct. Represents a named type's
    declaration.
    """

    name: str

    def swift_name(self) -> str:
        """Give the name our own prefix to avoid naming clashes with
        WGPU.
        """

        if not self.name.startswith("WGPU"):
            raise Exception(
                f"Unable to reprefix name of type because it doesn't"
                f" start with 'WGPU': '{self.name}'"
            )
        return "KZ" + self.name[4:]

    def convert_to_c(self, identifier: str) -> str:
        """Returns a string containing the Swift code to turn the given
        identifier into its underlying c representation. For example it's
        used to generate the code that converts values before passing them
        to a C function.
        """

        raise Exception("Unimplemented")


@dataclass()
class EnumCase:
    name: str
    value: str


@dataclass()
class Enum(TypeDecl):
    name: str
    raw_type: str
    cases: list[EnumCase]

    def convert_to_c(self, identifier: str) -> str:
        return f"{identifier}.c.rawValue"


@dataclass()
class Member:
    name: str
    type_: str


@dataclass()
class Method:
    name: str
    c_name: str
    parameters: list[FunctionParameter]
    return_type: str


@dataclass()
class Struct(TypeDecl):
    name: str
    members: list[Member]
    methods: list[Method]

    def convert_to_c(self, identifier: str) -> str:
        return f"{identifier}.c"
