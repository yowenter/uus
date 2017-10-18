import sys
import os

uus_conf_path = "/opt/lenovo/UnifiedService/webroot/bin/config/global.conf"
uus_conf_template = "/opt/lenovo/UnifiedService/global.conf.tpl"


MYSQL_USER = os.getenv("MYSQL_USER","root")
MYSQL_PASS = os.getenv("MYSQL_PASS","root")
MYSQL_HOST = os.getenv("MYSQL_HOST")
MYSQL_PORT = os.getenv("MYSQL_PORT",3306)
MYSQL_DB   = os.getenv("MYSQL_DB","uim_service")

if __name__=='__main__':
	if MYSQL_USER and MYSQL_PASS and MYSQL_HOST:
		with open(uus_conf_template,'r') as f:
			s = f.read()
			dest = s.format(MYSQL_USER=MYSQL_USER,MYSQL_PASS=MYSQL_PASS,MYSQL_HOST=MYSQL_HOST,MYSQL_PORT=MYSQL_PORT,MYSQL_DB=MYSQL_DB)
 		with open(uus_conf_path,'w') as f:
			print "writing config ",dest
			f.write(dest)
	else:
		print "`MYSQL_USER  or MYSQL_PASS or MYSQL_HOST or MYSQL_DB or MYSQL_PORT environment not configured.`"
		sys.exit(1)

