"""

This module provides expression parsing utility functions.
This acts as a wrapper for SimpleEval library (https://github.com/danthedeckie/simpleeval).
Hides implementation and provides a provision to switch to any parsing library.

"""

from simpleeval import SimpleEval


def parse(expression, operators=None, functions=None, variables=None):
    expr = ExpressionParser(operators=operators, functions=functions, variables=variables)
    return expr.parse(expression)


class ExpressionParser(object):
    expression = ""

    def __init__(self, operators=None, functions=None, variables=None):
        self.operators = operators
        self.functions = functions
        self.variables = variables

    def parse(self, expression):
        self.expression = expression
        s = SimpleEval(operators=self.operators, functions=self.functions, names=self.variables)
        return s.eval(expression)
