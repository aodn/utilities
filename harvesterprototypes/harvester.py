import logging
from datetime import datetime
from enum import Enum
from etl.db_interactions import DatabaseInteractions


def format_exception(exception):
    """Return a pretty string representation of an Exception object containing the Exception name and message
    :param exception: :py:class:`Exception` object
    :return: string
    """
    return "{cls}: {message}".format(cls=exception.__class__.__name__, message=exception)


class HandlerResult(Enum):
    UNKNOWN = 0
    SUCCESS = 1
    ERROR = 2


class GenericCsvHarvester(object):
    def __init__(self, config=None):

        # property backing variables
        self._config = None
        self._error = None
        self._error_details = None
        self._result = HandlerResult.UNKNOWN
        self._logger = None

        # public attributes
        self.config = config

    @property
    def config(self):
        """Property to access the :attr:`config` attribute
        :return: configuration object
        :rtype: :class:`aodncore.pipeline.config.LazyConfigManager`
        """
        return self._config

    @config.setter
    def config(self, value):
        self._config = value

    @property
    def error(self):
        """Read-only property to access :py:class:`Exception` object from handler instance
        :return: the exception object which caused the handler to fail (if applicable)
        :rtype: :class:`Exception`, :class:`None`
        """
        return self._error

    @property
    def error_details(self):
        """Read-only property to retrieve string description of error from handler instance
        :return: error description string (if applicable)
        :rtype: :class:`str`, :class:`None`
        """
        return self._error_details

    @property
    def result(self):
        """Read-only property to retrieve the overall end result of the handler instance
        :return: handler result
        :rtype: :class:`aodncore.pipeline.common.HandlerResult`
        """
        return self._result

    @property
    def logger(self):
        """Read-only property to access the instance Logger
        :return: :py:class:`Logger`
        """
        if self._logger is None:
            logging.basicConfig(format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p',
                                filename=datetime.now().strftime('logs/logfile_%H_%M_%d_%m_%Y.log'),
                                level=logging.DEBUG)
        self._logger = logging
        return self._logger

    def _handle_error(self, exception, system_error=False):
        self._error = exception
        self._result = HandlerResult.ERROR

        try:
            if system_error:
                self.logger.exception(format_exception(exception))

                import traceback
                self._error_details = traceback.format_exc()

            else:
                self.logger.error(format_exception(exception))
                self._error_details = str(exception)
        except Exception as e:
            self.logger.exception('error during _handle_error method: {e}'.format(e=format_exception(e)))

    def _handle_success(self):
        self._result = HandlerResult.SUCCESS

    def opinionated_harvester(self):
        with DatabaseInteractions(config=self.config, logger=self.logger) as db:
            self.logger.info('1. run ddl steps')
            db.run_ddl()

            self.logger.info('2. load CSVs into database')
            db.copy_from_csv_bulk(truncate=True)

            self.logger.info('3. run dml scripts')
            db.run_dml()

            self.logger.info('4. refresh materialized views')
            db.refresh_materialized_view_bulk()

            self.logger.info('5. update metadata')
            self.logger.info('  oops... not implemented yet')

            self.logger.info('6. harvest complete')

    def unopinionated_harvester(self):
        with DatabaseInteractions(config=self.config, logger=self.logger) as db:
            self.logger.info('1. run_ddl')
            db.run_ddl()

            num = 2
            for step in self.config['steps']:
                args = step.get('args')
                self.logger.info('{}. {}'.format(num, step['name']))
                if args:
                    getattr(db, step['name'])(**args)
                else:
                    getattr(db, step['name'])()
                num += 1

            self.logger.info('{}. harvest complete'.format(num))
