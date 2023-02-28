from pycparser import c_ast

_type_rewrites = {
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
    "UnsafeMutablePointer<Void>?": "UnsafeMutableRawPointer?",
    "UnsafePointer<Void>?": "UnsafeRawPointer?",
    "UnsafePointer<CChar>?": "String"
}
_swift_keywords = ["internal", "default", "repeat"]
_shorthand_replacements = {
    "src": "source",
    "dst": "destination",
    "userdata": "userData"
}
_acronyms = [
    "CPU",
    "GPU",
    "GL"
]


def _rewrite_type(name: str) -> str:
    if name in _type_rewrites:
        return _type_rewrites[name]
    else:
        return name


def c_type_to_swift_type(t) -> str:
    if type(t) == c_ast.TypeDecl:
        return _rewrite_type(t.type.names[0])
    elif type(t) == c_ast.PtrDecl:
        inner = _rewrite_type(t.type.type.names[0])

        qualifier = ""
        if "const" not in t.quals and "const" not in t.type.quals:
            qualifier = "Mutable"

        return _rewrite_type(f"Unsafe{qualifier}Pointer<{inner}>?")
    else:
        raise Exception("Unable to convert C type to Swift Type: " + t)


def stringify(node) -> str:
    if type(node) == c_ast.Constant:
        return node.value
    elif type(node) == c_ast.ID:
        return node.name
    elif type(node) == c_ast.BinaryOp:
        left = stringify(node.left)
        right = stringify(node.right)
        return f"{left} {node.op} {right}"
    else:
        raise Exception(f"Failed to stringify a node: '{node}'")


def detect_casing(identifier: str) -> str:
    """Returns the most likely casing scheme used by a given identifier.
    A very rough heuristic method is used to identify the casing. The
    algorithm can be updated in future if it is not sophisticated
    enough.
    """

    all_caps = True
    for c in identifier:
        if c.isalpha() and c.islower():
            all_caps = False
            break
    if all_caps:
        return "screaming_snake"
    elif identifier[0].isupper():
        return "upper_camel"
    elif identifier[0].islower():
        return "snake" if "_" in identifier else "lower_camel"
    else:
        return "unknown"


def swiftify_identifier(identifier: str) -> str:
    if identifier in _acronyms:
        return identifier.lower()

    casing = detect_casing(identifier)
    parts = []
    if casing == "snake" or casing == "screaming_snake":
        parts = identifier.lower().split("_")
        parts = [part.lower() for part in parts if part != ""]
    elif casing == "lower_camel" or casing == "upper_camel":
        lower_camel = identifier[0].lower() + identifier[1:]
        parts = []
        current_part = ""
        for c in lower_camel:
            if c.isupper():
                parts.append(current_part)
                current_part = c.lower()
            else:
                current_part += c.lower()
        if current_part != "":
            parts.append(current_part)
    else:
        parts = [identifier]

    for (i, part) in enumerate(parts):
        parts[i] = _shorthand_replacements.get(part, part)
        if part in _shorthand_replacements:
            parts[i] = _shorthand_replacements[part]

    for (i, part) in enumerate(parts[1:]):
        parts[i + 1] = part[0].upper() + part[1:]

    swift_identifier = "".join(parts)
    if swift_identifier in _swift_keywords:
        swift_identifier = f"`{swift_identifier}`"
    elif not swift_identifier[0].isalpha():
        swift_identifier = f"_{swift_identifier}"
    return swift_identifier
