"""

"""


class HeadOutput(object):
    """

    """

    def __init__(self, num_lines):
        self.num_lines = num_lines

    def output(self, source):
        print(source.field_names)

        lines_so_far = 0

        for record in source.records:
            if lines_so_far < self.num_lines:
                print(record.values)

            lines_so_far += 1

