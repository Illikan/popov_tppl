from enum import Enum, auto

class TokenType(Enum):
    NUMBER = auto()
    OPERATOR = auto()
    EOL = auto()
    # PLUS = auto()
    # MINUS = auto()
    # MUL = auto()
    # DIV = auto()

class Token():
    def __init__(self, type_: TokenType, value: str):
        self.type_ = type_
        self.value = value

    def __str__(self):
        return f"{self.__class__.__name__}({self.type}, {self.value})"