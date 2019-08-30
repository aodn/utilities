def format_dict(dictionary):
    return ", ".join(["{}='{}'".format(key, value) for key, value in dictionary.items()])


def reduce_space(value):
    return ' '.join(value.split())
