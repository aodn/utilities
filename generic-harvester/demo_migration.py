from migration.run_alembic import RunAlembic

import json
import os

schemas = ["file_index", "abos_sofs_fl", "anmn_ts"]

for schema in schemas:
    print("Running migrations for schema {}...".format(schema))
    config_file = "config/{}.json".format(schema)

    with open(config_file) as f:
        config = json.load(f)

    db_params = config["db_params"]

    script_location = os.path.join("migration", db_params["schema"])
    url = db_params["driver"]+"://"+db_params["user"]+":"+db_params["password"]+"@"+db_params["host"]+":"+db_params["port"]+"/"+db_params["database"]

    run = RunAlembic(script_location, url)

    run.do_upgrade("head")

    # run.do_downgrade("base")


