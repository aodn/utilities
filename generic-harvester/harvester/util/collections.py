from collections import OrderedDict


def subset(dictionary, keys):
    return OrderedDict((key, value) for key, value in dictionary.items() if key in keys)
