#!/bin/bash

cat <<EOT > /etc/supervisord.conf
[supervisord]
nodaemon=true
[program:lighttpd]
command= lighttpd -D -f /etc/lighttpd/lighttpd.conf
autorestart=true
startsecs=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
[program:app]
command=python /opt/lenovo/UnifiedService/webroot/bin/ServerStart.pyc
autorestart=true
startsecs=0
stderr_logfile=/dev/stderr
stderr_logfile_maxbytes=0
stdout_logfile=/dev/stdout
stdout_logfile_maxbytes=0
EOT
echo "Init configuration."
/etc/init.d/lxiserver start 
python /opt/lenovo/UnifiedService/render_conf.py
echo "Sync db"
#python /opt/lenovo/UnifiedService/webroot/bin/keepDBupdate.pyc
exec supervisord
