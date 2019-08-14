from alembic.command import upgrade, downgrade
from alembic.config import Config
import os


def get_config():
    """ retrieves the directory that *this* file is in """
    migrations_dir = os.path.dirname(os.path.realpath(__file__))
    config_file = os.path.join(migrations_dir, "../alembic.ini")

    alembic_cfg = Config(file_=config_file)
    alembic_cfg.set_main_option("script_location", migrations_dir)
    alembic_cfg.set_main_option("sqlalchemy.url",
                                "postgresql+psycopg2://abos_sofs_fl:abos_sofs_fl@localhost/test_abos_sofs_fl")
    return alembic_cfg


def do_upgrade(revision):
    """ upgrade the database to the latest revision """
    upgrade(get_config(), revision)


def do_downgrade(revision):
    """ downgrade the database to the base revision """
    downgrade(get_config(), revision)


# from alembic.config import Config
# from alembic import command, autogenerate
# from alembic.script import ScriptDirectory
# from alembic.runtime.environment import EnvironmentContext
#
# alembic_cfg = Config()
# alembic_cfg.set_main_option("script_location", "alembic")
# alembic_cfg.set_main_option("sqlalchemy.url", "postgresql+psycopg2://abos_sofs_fl:abos_sofs_fl@localhost/test_abos_sofs_fl")
# command.upgrade(alembic_cfg, 'head')

# alembic_script = ScriptDirectory.from_config(alembic_cfg)
# alembic_env = EnvironmentContext(alembic_cfg, alembic_script)
#
# conn = engine.connect()
# alembic_env.configure(connection=conn, target_metadata=metadata)
# alembic_context = alembic_env.get_context()
#
# alembic_env.configure(connection=conn, target_metadata=metadata, fn=do_upgrade)
#
# with alembic_env.begin_transaction():
#     alembic_env.run_migrations()
#
# autogenerate.compare_metadata(alembic_context, metadata)
# autogenerate.produce_migrations(alembic_context, metadata)
#
# def do_upgrade(revision, context):
#     return alembic_script._upgrade_revs(script.get_heads(), revision)
