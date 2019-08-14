from collections import OrderedDict


def subset(dictionary, keys):
    """
    Return a subset of the dictionary specified by keys as a new OrderedDict
    :param dictionary: dictionary from which subset is to be taken
    :param keys: keys specifying subset to take
    :return: An OrderedDict containing the subset
    """
    return OrderedDict((key, value) for key, value in dictionary.items() if key in keys)


def zip_list(iter1, iter2):
    """
    Return a list of OrderedDicts created by zipping iter1 with each iterable in iter2
    :param iter1: iterable to be zipped with iterables in iter2
    :param iter2: iterable containing iterables to be zipped
    :return: A list of OrderedDicts
    """
    return [OrderedDict(zip(iter1, item)) for item in iter2]


