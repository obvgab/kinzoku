from pycparser import c_ast

swift_keywords = ["internal", "default", "repeat"]
replacements = {
    "src": "source",
    "dst": "destination"
}
acronyms = [
    "CPU",
    "GPU",
    "GL"
]

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
    if identifier in acronyms:
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
        parts[i] = replacements.get(part, part)
        if part in replacements:
            parts[i] = replacements[part]

    for (i, part) in enumerate(parts[1:]):
        parts[i + 1] = part[0].upper() + part[1:]

    swift_identifier = "".join(parts)
    if swift_identifier in swift_keywords:
        swift_identifier = f"`{swift_identifier}`"
    elif not swift_identifier[0].isalpha():
        swift_identifier = f"_{swift_identifier}"
    return swift_identifier
