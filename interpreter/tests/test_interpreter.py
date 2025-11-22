import pytest
from interpreter import Interpreter

class TestInterpreter:
    interpreter = Interpreter()
    def test_simple_add(self):
        assert self.interpreter.eval("2+2") == 4
        assert self.interpreter.eval("2+3") == 5

    def test_simple_sub(self):
        assert self.interpreter.eval("2-2") == 0
        assert self.interpreter.eval("2-3") == -1

    def test_spaces(self):
        assert self.interpreter.eval("      2     +  2       ") == 4

    def test_numbers(self):
        assert self.interpreter.eval("21 + 21") == 42