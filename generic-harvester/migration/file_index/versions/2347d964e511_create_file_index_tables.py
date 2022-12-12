"""create file index tables

Revision ID: 2347d964e511
Revises: 
Create Date: 2019-08-21 08:12:41.256965

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.schema import Sequence, CreateSequence, DropSequence


revision = '2347d964e511'
down_revision = None
branch_labels = None
depends_on = None


def upgrade():
    op.execute(CreateSequence(Sequence('indexed_file_id_seq')))
    op.create_table(
        'indexed_file',
        sa.Column('id', sa.INTEGER, nullable=False, server_default=sa.text("nextval('indexed_file_id_seq'::regclass)")),
        sa.Column('url', sa.VARCHAR(512), nullable=False),
        sa.Column('created', sa.TIMESTAMP(timezone=True)),
        sa.Column('modified', sa.TIMESTAMP(timezone=True)),
        sa.Column('first_indexed', sa.TIMESTAMP(timezone=True), server_default=sa.text('now()')),
        sa.Column('last_indexed', sa.TIMESTAMP(timezone=True)),
        sa.Column('last_indexed_run', sa.INTEGER),
        sa.Column('size', sa.dialects.postgresql.DOUBLE_PRECISION),
        sa.Column('deleted', sa.BOOLEAN, server_default=sa.schema.DefaultClause("0")),
        sa.PrimaryKeyConstraint('id', name='indexed_file_pk')
    )
    op.create_index('indexed_file_deleted_idx', 'indexed_file', ['deleted'])
    op.execute("GRANT SELECT, REFERENCES ON TABLE indexed_file TO PUBLIC")

    op.create_table(
        'nc_global_attribute',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('name', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('type', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('value', sa.dialects.postgresql.TEXT, nullable=False)
    )
    op.execute("GRANT SELECT ON TABLE nc_global_attribute TO PUBLIC")

    op.create_table(
        'nc_variable',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('name', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('type', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('dimensions', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('shape', sa.dialects.postgresql.TEXT, nullable=False)
    )

    op.create_table(
        'nc_variable_attribute',
        sa.Column('file_id', sa.BIGINT, nullable=False),
        sa.Column('var_name', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('attr_name', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('type', sa.dialects.postgresql.TEXT, nullable=False),
        sa.Column('value', sa.dialects.postgresql.TEXT, nullable=False)
    )


def downgrade():
    op.drop_table('nc_global_attribute')
    op.drop_table('nc_variable')
    op.execute("REVOKE SELECT ON nc_variable_attribute FROM PUBLIC")
    op.drop_table('nc_variable_attribute')

    op.execute("REVOKE SELECT, REFERENCES ON indexed_file FROM PUBLIC")
    op.drop_index('indexed_file_deleted_idx')
    op.drop_table('indexed_file')
    op.execute(DropSequence(Sequence('indexed_file_id_seq')))
