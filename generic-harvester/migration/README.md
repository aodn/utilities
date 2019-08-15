# Alembic

[Alembic](https://alembic.sqlalchemy.org/) is a lightweight database migration tool for usage with the [SQLAlchemy](https://www.sqlalchemy.org/). It uses Python library as the underlying engine for writing your database schema.

## Setting up the Alembic:

#### 1. First, create the alembic using command  _alembic init <name>_

    alembic init migration

This will create the directory structure as below:

    yourproject/
      migration/
        env.py
        README
        script.py.mako
        versions/ 
      alembic.ini

#### 2. Modify the database connection URL in the  alembic.ini

    sqlalchemy.url = <driver>://<user>:<pass>@<hostaddress>:<port>/<dbname>
    
    Example:
    sqlalchemy.url = postgresql+psycopg2://abos_sofs_fl:abos_sofs_fl@localhost:5432/abos_sofs_fl

#### 3. Run  `alembic revision` command  to create a template for a new migration script

    alembic  revision  -m  'create table abos_sofs_fl'

A new file  `dd40085d47ea_create_table_abos_sofs_fl.py`  is generated. Looking inside the file:


    """create table abos_sofs_fl  
      
    Revision ID: dd40085d47ea  
    Revises: Create Date: 2019-08-09 09:35:43.039230  
      
    """
    from alembic import op
    import sqlalchemy as sa
    
    # revision identifiers, used by Alembic.
    revision = 'dd40085d47ea'  
    down_revision = None  
    branch_labels = None  
    depends_on = None
    
    def upgrade():
        pass
    
    def downgrade():
        pass

#### 4. Add directives to the script, here adding a new table `timeseries`:

    def upgrade():
        op.create_table(
            'timeseries',
            sa.Column('deployment_number', sa.VARCHAR(3), nullable=False),  
		    sa.Column('mean_latitude', sa.dialects.postgresql.DOUBLE_PRECISION),  
		    sa.Column('mean_longitude', sa.dialects.postgresql.DOUBLE_PRECISION),  
		    sa.Column('geom', geoal2.Geometry(geometry_type='Geometry', srid=4326)),  
		    sa.Column('time_deployment_start', sa.TIMESTAMP(timezone=True)),  
		    sa.Column('time_deployment_end', sa.TIMESTAMP(timezone=True)),  
		    sa.PrimaryKeyConstraint('deployment_number', name='timeseries_pk'),  
		    sa.CheckConstraint(geoal2.functions.ST_IsValid(sa.text('geom')), name='timeseries_geom_check')  
		)
		    
    def downgrade():
        op.drop_table('timeseries')

#### 5. Run `alembic  upgrade`command to upgrade to target revision

    Note: Before running migration, make sure to create database, schema and roles.  

The  `alembic  upgrade`command will run upgrade operations, proceeding from the current database revision, in this example  `None`, to the given target revision.  In this case `dd40085d47ea`, telling  to upgrade to targeted revision. We can specify  `head`,  to upgrade to “the most recent” revision. 

    $ alembic upgrade dd40085d47ea
    INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
    INFO  [alembic.runtime.migration] Will assume transactional DDL.
    INFO  [alembic.runtime.migration] Running upgrade  -> dd40085d47ea, create table abos_sofs_fl

#### 6. Run `alembic  downgrade` command to downgrade to target revision

The  `alembic  downgrade`command will run downgrade operations, proceeding from the current database revision, to the given target revision.  In this case  `base`, telling to downgrade to initial state before revision. We can specify `dd40085d47ea`  to downgrade to targeted revision.

    $ alembic downgrade base
    INFO  [alembic.runtime.migration] Context impl PostgresqlImpl.
    INFO  [alembic.runtime.migration] Will assume transactional DDL.
    INFO  [alembic.runtime.migration] Running downgrade dd40085d47ea -> , create table abos_sofs_fl

#### 7. Run `alembic  upgrade/downgrade` command from python code

    from alembic.command import upgrade, downgrade  
	from alembic.config import Config  
	  
	config_file = "alembic.ini"  
	alembic_cfg = Config(file_=config_file)  
	upgrade(alembic_cfg, 'dd40085d47ea') 
	downgrade(alembic_cfg, 'base') 
	