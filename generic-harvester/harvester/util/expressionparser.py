"""

This module provides expression parsing utility functions.
This acts as a wrapper for SimpleEval library (https://github.com/danthedeckie/simpleeval).
Hides implementation and provides a provision to switch to any parsing library.

"""

from simpleeval import SimpleEval


def parse(expression, operators=None, functions=None, names=None):
    """ parse(defn["value"], names=variables, functions={"re": re}) """
    expr = ExpressionParser(operators=operators, functions=functions, names=names)
    return expr.parse(expression)


class ExpressionParser(object):
    expression = ""

    def __init__(self, operators=None, functions=None, names=None):
        self.operators = operators
        self.functions = functions
        self.names = names

    def parse(self, expression):
        self.expression = expression
        s = SimpleEval(operators=self.operators, functions=self.functions, names=self.names)
        return s.eval(expression)
