from .token import TokenType, Token
class Interpreter():
    
    def __init__(self):
        self._pos = 0
        self._current_token = None
        self._text = ""
        self._current_char = None
    def __check_token_type(self, type_: TokenType):
        if self._current_token.type_ == type_:
            self._current_token = self.__next_token()
        else:
            raise SyntaxError("Invalid token type")

    def _forward(self):
        self._pos += 1
        if self._pos >= len(self._text):
            self._current_char = None
        else:
            self._current_char = self._text[self._pos] 

    def __skip(self):
        while self._current_char is not None and self._current_char.isspace():
            self._forward()

    def __next_token(self) -> Token:
        while self._current_char:
            if self._current_char.isspace():
                self.__skip()
                continue
            current_char = self._current_char
            if self._current_char.isdigit():
                self._forward()
                return Token(TokenType.NUMBER, current_char)
            if self._current_char in ["+", "-"]:
                self._forward()
                return Token(TokenType.OPERATOR, current_char)
            if self._current_char == " ":
                self._forward()
                return self.__next_token()
            raise SyntaxError()

    def __expr(self)-> float:
        self._current_token = self.__next_token()
        left_token = self._current_token
        self.__check_token_type(TokenType.NUMBER)
        operator = self._current_token
        self.__check_token_type(TokenType.OPERATOR)
        right_token = self._current_token
        self.__check_token_type(TokenType.NUMBER)
        if operator.value == "+":
            return float(left_token.value) + float(right_token.value)
        if operator.value == "-":
            return float(left_token.value) - float(right_token.value)
        
        return RuntimeError("Invalid expression")
    
    def eval(self, expr: str) -> int:
        self._text = expr
        self._pos = 0
        self._current_token = None
        return self.__expr()
    
    