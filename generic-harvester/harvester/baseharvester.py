"""This module provides a common base class for harvester classes
"""


import abc

__all__ = [
    'BaseHarvester'
]


class BaseHarvester(object):
    """Base class of Harvester classes
    """

    __metaclass__ = abc.ABCMeta

    def __init__(self, config, logger):
        self._config = config
        self._logger = logger

    def __repr__(self):
        return "{self.__class__.__name__}()".format(self=self)

    @abc.abstractmethod
    def delete_harvested_data(self, source_file):
        pass

    @abc.abstractmethod
    def harvest_data(self, source_file):
        pass

    #
    # process methods - to be overridden by child class as required
    #

    def before_delete(self, source_file):  # pragma: no cover
        """Method designed to be overridden by child handlers in order to execute code before deleting harvested data
        :return: None
        """
        self.logger.sysinfo("`preprocess` not overridden by child class, skipping step")

    def after_delete(self, source_file):  # pragma: no cover
        """Method designed to be overridden by child handlers in order to execute code after deleting harvested data
        :return: None
        """
        self.logger.sysinfo("`postprocess` not overridden by child class, skipping step")

    def before_harvest(self, source_file):  # pragma: no cover
        """Method designed to be overridden by child handlers in order to execute code before harvesting data
        :return: None
        """
        self.logger.sysinfo("`preprocess` not overridden by child class, skipping step")

    def after_harvest(self, source_file):  # pragma: no cover
        """Method designed to be overridden by child handlers in order to execute code after harvesting data
        :return: None
        """
        self.logger.sysinfo("`postprocess` not overridden by child class, skipping step")

