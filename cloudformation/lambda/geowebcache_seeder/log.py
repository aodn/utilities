import logging


class SeederBaseObject(object):
    """This automatically assigns an appropriately named logger to each sub-class, so that they can simply start logging
    with no further setup required. It also injects a unique per-instance UUID
    """

    def __init__(self):
        logging.basicConfig()
        log_context = "{0}.{1}".format(self.__class__.__module__, self.__class__.__name__)
        self._logger = logging.getLogger(log_context)
        self._logger.setLevel(logging.DEBUG)

    def log(self, msg, level=logging.INFO):
        """Helper log method for regular messages
        :param msg: log message
        :param level: log level
        :return: None
        """
        self._logger.log(level, msg)

    def log_exception(self, msg):
        """Helper log method for logging exceptions
        :param msg: log message
        :return: None
        """
        self._logger.exception(msg)
