"""

"""


def to_console(source):
    """
    Output source records to console

    :return:
    """

    print(source.field_names())

    for record in source.records():
        print(record)

