from alembic.command import upgrade, downgrade
from alembic.config import Config
import os


class RunAlembic:

    def __init__(self, script_location, url):
        self.script_location = script_location
        self.url = url
        self.alembic_cfg = self.do_config()

    def do_config(self):
        """
        Create alembic configuration object
        :return: alembic configuration object
        """
        """ retrieves the directory that *this* file is in """
        migrations_dir = os.path.dirname(os.path.realpath(os.path.join(self.script_location)))
        config_file = os.path.join(migrations_dir, "alembic.ini")

        alembic_cfg = Config(file_=config_file)
        alembic_cfg.set_main_option("script_location", self.script_location)
        alembic_cfg.set_main_option("sqlalchemy.url", self.url)
        return alembic_cfg

    def do_upgrade(self, revision):
        """
        Upgrade database to the specified revsion
        :param revision: database revision
        :return:
        """
        upgrade(self.alembic_cfg, revision)

    def do_downgrade(self, revision):
        """
        Downgrade databse to the specified revision
        :param revision: database revision
        :return:
        """
        downgrade(self.alembic_cfg, revision)
