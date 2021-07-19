"""
Common code for record sources

Record sources generate records for output by record sinks
"""


class RecordSource(object):
    """
    Source records from an iterable
    """

    def __init__(self, iter1, field_names=None):
        self.iter1 = iter1
        self.field_names = field_names

    def records(self):
        return iter(self.iter1)
