#===============================================================================
# Service Config
#===============================================================================
# Log_Level=[debug | information | warning | error]
Log_Level        =debug
#Log_Size MegaBytes, if 0 then no backup log file
Log_Size        =5
#backupCount  of the log file
Log_Count        = 20
#Max text size (KByte) to write for one log 
Log_Text_Size = 1000


#Platform : need to be VCenter or SystemCenter
# 0: VMWare VCenter
# 1: Microsoft SystemCenter
# 3: Openstack
Platform=3
#The server name of UUS server
UUS_Server_FQDN=

# Whether using a secure protocal(https) to connect IMM CIM Interface
# 0 : will try http if https is disabled
# 1 : will always using https protocal to access to IMM CIM interface
SecureCIMConnection=0

#The server name of SCVMM server
SCVMM_Server_FQDN=

#The cim collection interval(minute), should be more when release
Cim_collect_interval		=60

#The host info collection interval(minute)
Host_collect_interval		=20

#The host info collection interval(minute)
OpenStack_collect_interval	=60

#The maximum thread number in slp discovery unicast mode
Max_Thread_Number=10
#KeyEncrypt_Type = 1
#Key_Blob = 010100000000000000000100280E1D5603D6BD38219FBF9EF63ECD6465E12AD0406FE544C0F5FFF47AC271689C8F245F5899CACFA8A6F7980A3F62661B8BA0650DD541D60159503199DD32E657099A5FC7F9DADCFBC48CAD1491BA2D3DAB70964EC4344D235A668AA28DEA23C6E14CF769217AE99452B3126FFFDF7C051BC55189CED1FC3DE0F5B9ABACB62E6CB5503A6DB916BAF6CF63A3B31AC26DE0F75DA5689B0C412C26A9A31070243863F81A1917BE1D380DE8F4B71D7AD39C9DA1BD86ACB5E24371D92EDFDC716A9FC45903D3C80979B90E87A1CE29F5847EBA0B2A218BC7CBE56CFC46D2AEC2E164A48DD870A2B24FDEAD43AAF133330F556EE8EBFA37CDCDDAF77E146A23EC2E5F
KeyEncrypt_Type = 0
Key_Blob = MTIzNDU2Nzg5MEFCQ0RFRg==
#===============================================================================
# DB config
#===============================================================================
# support "mysql" or "postgresql" or "sqlite"
DBCHOICE		= mysql  

# For mysql
DBNAME			= uim_service
USERNAME		= {MYSQL_USER}
PASSWORD		= {MYSQL_PASS}
DBPORT          = {MYSQL_PORT}
MYSQL_VIP_URL = mysql+mysqldb://{MYSQL_USER}:{MYSQL_PASS}@{MYSQL_HOST}:{MYSQL_PORT}/{MYSQL_DB}?charset=utf8
                                               
# For Postgresql
#DBNAME			= uim_service
#USERNAME		= postgres
#PASSWORD		= postgres
#DBPORT         = 5433

# For Sqlite, file name of sqlite db, located at webroot/bin/data/db
SQLITENAME		= ivp.db

#===============================================================================
# openstack config
#===============================================================================

# pmtsl config
PMTSL_USER = admin123
PMTSL_PASS = admin123
PMTSL_PORT = 8443

# imm listening address using vip
DISCARD_IMM_LISTENING_VIP_URL = 0.0.0.0

#The host onlive check interval(minute)
OpenStack_checkOnline_interval	=20

# debug mode: TRUE or FALSE
DEBUG_MODE        = TRUE
