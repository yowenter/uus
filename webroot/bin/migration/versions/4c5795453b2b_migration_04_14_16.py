"""migration_04_14_16

Revision ID: 4c5795453b2b
Revises: 2ef80eb77e7f
Create Date: 2016-04-14 07:44:00.080258

"""

# revision identifiers, used by Alembic.
revision = '4c5795453b2b'
down_revision = '2ef80eb77e7f'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.create_table('PMSwitch',
    sa.Column('uuid', sa.String(100), nullable=False),
    sa.Column('ip', sa.String(100), nullable=True),
    sa.Column('ssh_port', sa.String(100), nullable=True),
    sa.Column('username', sa.String(100), nullable=True),
    sa.Column('password', sa.String(100), nullable=True),
    sa.PrimaryKeyConstraint('uuid')
    )
    op.create_table('PMNode',
    sa.Column('id', sa.Integer(), nullable=False),
    sa.Column('uuid', sa.String(100), nullable=True),
    sa.Column('node_id', sa.String(100), nullable=True),
    sa.Column('interface', sa.String(100), nullable=True),
    sa.ForeignKeyConstraint(['uuid'], ['PMSwitch.uuid'], onupdate='CASCADE', ondelete='CASCADE'),
    sa.PrimaryKeyConstraint('id')
    )
    op.alter_column(u'IMM', 'account_verified',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'IMM', 'cim_http_enabled',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'IMM', 'cim_https_enabled',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'IMM', 'enable_power_poll',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'IMM', 'substribe_imm',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'RAS_template', 'editable',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'RaidStoragePool', 'Primordial',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'RaidStorageVolume', 'Bootable',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'RaidStorageVolume', 'PrimaryPartition',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'Switch', 'account_verified',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    op.alter_column(u'physical_memory', 'is_speed_in_mhz',
               existing_type=mysql.TINYINT(display_width=1),
               type_=sa.Boolean(),
               existing_nullable=True)
    ### end Alembic commands ###


def downgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.alter_column(u'physical_memory', 'is_speed_in_mhz',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'Switch', 'account_verified',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'RaidStorageVolume', 'PrimaryPartition',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'RaidStorageVolume', 'Bootable',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'RaidStoragePool', 'Primordial',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'RAS_template', 'editable',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'IMM', 'substribe_imm',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'IMM', 'enable_power_poll',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'IMM', 'cim_https_enabled',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'IMM', 'cim_http_enabled',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.alter_column(u'IMM', 'account_verified',
               existing_type=sa.Boolean(),
               type_=mysql.TINYINT(display_width=1),
               existing_nullable=True)
    op.drop_table('PMNode')
    op.drop_table('PMSwitch')
    ### end Alembic commands ###
