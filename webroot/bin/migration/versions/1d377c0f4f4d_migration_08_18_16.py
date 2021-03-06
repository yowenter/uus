"""migration_08_18_16

Revision ID: 1d377c0f4f4d
Revises: 4c5795453b2b
Create Date: 2016-08-18 03:02:01.672752

"""

# revision identifiers, used by Alembic.
revision = '1d377c0f4f4d'
down_revision = '4c5795453b2b'

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import mysql

def upgrade():
    ### commands auto generated by Alembic - please adjust! ###
    op.create_table('UpgradeStatus',
    sa.Column('timestamp', sa.String(length=100), nullable=False),
    sa.Column('status', sa.String(length=100), nullable=True),
    sa.Column('result', sa.String(length=100), nullable=True),
    sa.PrimaryKeyConstraint('timestamp')
    )
    op.create_table('SwitchOID',
    sa.Column('hardware_type', sa.String(length=100), nullable=False),
    sa.Column('os_era', sa.String(length=100), nullable=False),
    sa.Column('object_name', sa.String(length=100), nullable=True),
    sa.Column('oid', sa.String(length=100), nullable=True),
    sa.PrimaryKeyConstraint('hardware_type', 'os_era')
    )
    op.create_table('SwitchData',
    sa.Column('uuid', sa.String(length=100), nullable=False),
    sa.Column('content_type', sa.String(length=100), nullable=False),
    sa.Column('content_value', sa.String(length=100), nullable=True),
    sa.ForeignKeyConstraint(['uuid'], ['Switch.uuid'], ),
    sa.PrimaryKeyConstraint('uuid', 'content_type')
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
    op.add_column(u'Switch', sa.Column('content_source', sa.String(length=100), nullable=True))
    op.add_column(u'Switch', sa.Column('error_message', sa.String(length=100), nullable=True))
    op.add_column(u'Switch', sa.Column('hardware_type', sa.String(length=100), nullable=True))
    op.add_column(u'Switch', sa.Column('last_updated_date', sa.DateTime(), nullable=True))
    op.add_column(u'Switch', sa.Column('os_era', sa.String(length=100), nullable=True))
    op.alter_column(u'Switch', 'ip',
               existing_type=mysql.VARCHAR(length=100),
               type_=sa.String(length=20),
               existing_nullable=True)
    op.create_unique_constraint(None, 'Switch', ['ip'])
    op.drop_column(u'Switch', 'status')
    op.drop_column(u'Switch', 'last_visit_date')
    op.drop_column(u'Switch', 'hostname')
    op.drop_column(u'Switch', 'account_verified')
    op.drop_column(u'Switch', 'mac')
    op.drop_column(u'Switch', 'osVer')
    op.drop_column(u'Switch', 'serialNum')
    op.drop_column(u'Switch', 'memory')
    op.drop_column(u'Switch', 'cpu')
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
    op.add_column(u'Switch', sa.Column('cpu', mysql.VARCHAR(length=100), nullable=True))
    op.add_column(u'Switch', sa.Column('memory', mysql.VARCHAR(length=100), nullable=True))
    op.add_column(u'Switch', sa.Column('serialNum', mysql.VARCHAR(length=100), nullable=True))
    op.add_column(u'Switch', sa.Column('osVer', mysql.VARCHAR(length=100), nullable=True))
    op.add_column(u'Switch', sa.Column('mac', mysql.VARCHAR(length=100), nullable=True))
    op.add_column(u'Switch', sa.Column('account_verified', mysql.TINYINT(display_width=1), autoincrement=False, nullable=True))
    op.add_column(u'Switch', sa.Column('hostname', mysql.VARCHAR(length=100), nullable=True))
    op.add_column(u'Switch', sa.Column('last_visit_date', mysql.DATETIME(), nullable=True))
    op.add_column(u'Switch', sa.Column('status', mysql.VARCHAR(length=100), nullable=True))
    op.drop_constraint(None, 'Switch', type_='unique')
    op.alter_column(u'Switch', 'ip',
               existing_type=sa.String(length=20),
               type_=mysql.VARCHAR(length=100),
               existing_nullable=True)
    op.drop_column(u'Switch', 'os_era')
    op.drop_column(u'Switch', 'last_updated_date')
    op.drop_column(u'Switch', 'hardware_type')
    op.drop_column(u'Switch', 'error_message')
    op.drop_column(u'Switch', 'content_source')
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
    op.drop_table('SwitchData')
    op.drop_table('SwitchOID')
    op.drop_table('UpgradeStatus')
    ### end Alembic commands ###
