FROM ubuntu:16.04

RUN apt-get update
RUN apt-get install -y python-pip
RUN apt-get install -y python-m2crypto
RUN apt-get install -y libssl-dev
RUN apt-get install -y libmysqlclient-dev
RUN pip install -i http://pypi.douban.com/simple/  --trusted-host pypi.douban.com IPy
RUN pip install -i http://pypi.douban.com/simple/  --trusted-host pypi.douban.com flup
RUN pip install -i http://pypi.douban.com/simple/  --trusted-host pypi.douban.com alembic
RUN pip install -i http://pypi.douban.com/simple/  --trusted-host pypi.douban.com MySQL-python
RUN pip install -i http://pypi.douban.com/simple/  --trusted-host pypi.douban.com pexpect
RUN pip install -i http://pypi.douban.com/simple/  --trusted-host pypi.douban.com requests
RUN pip install -i http://pypi.douban.com/simple/  --trusted-host pypi.douban.com pywbem
RUN pip uninstall -y M2Crypto
RUN pip install -i http://pypi.douban.com/simple/  --trusted-host pypi.douban.com supervisor


RUN apt-get install -y software-properties-common
#RUN add-apt-repository -y ppa:nginx/stable
#RUN apt-get update
#RUN apt-get install -y nginx
RUN apt-get install -y lighttpd

COPY  lighttpd.conf  /etc/lighttpd/lighttpd.conf



COPY supervisord.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/supervisord.sh
#COPY nginx /etc/nginx/

RUN mkdir -p /opt/lenovo/UnifiedService
WORKDIR /opt/lenovo/UnifiedService
ADD . /opt/lenovo/UnifiedService
EXPOSE 80
CMD ["sh","/usr/local/bin/supervisord.sh"]

