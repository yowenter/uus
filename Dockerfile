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


# install some dependency
RUN apt-get install -y apparmor blt docutils-common docutils-doc fontconfig fontconfig-config fonts-dejavu-core fonts-liberation graphviz \
  libaio1 libapparmor-perl libbsd0 libcairo2 libcdt5 libcgi-fast-perl libcgi-pm-perl libcgraph6 libdatrie1 libedit2 \
  libencode-locale-perl libevent-core-2.0-5 libfcgi-perl libfontconfig1 libfreetype6 libgd3 libgraphite2-3 libgvc6 \
  libgvpr2 libharfbuzz0b libhtml-parser-perl libhtml-tagset-perl libhtml-template-perl libhttp-date-perl \
  libhttp-message-perl libice6 libio-html-perl libjbig0 libjpeg-turbo8 libjpeg8 liblcms2-2 libltdl7 \
  liblwp-mediatypes-perl libnuma1 libpango-1.0-0 libpangocairo-1.0-0 libpangoft2-1.0-0 libpaper-utils libpaper1 \
  libpathplan4 libpixman-1-0 libpng12-0 libslp1 libsm6 libtcl8.6 libthai-data libthai0 libtiff5 libtimedate-perl \
  libtk8.6 liburi-perl libvpx3 libwebp5 libwebpmux1 libwrap0 libx11-6 libx11-data libxau6 libxaw7 libxcb-render0 \
  libxcb-shm0 libxcb1 libxdmcp6 libxext6 libxft2 libxmu6 libxpm4 libxrender1 libxss1 libxt6  \
  psmisc python-attr python-cffi-backend \
  python-chardet python-cryptography python-docutils python-enum34 python-epydoc python-flup python-idna \
  python-ipaddress python-ipy python-openssl python-pam python-pil python-pyasn1 python-pyasn1-modules \
  python-pygments python-pywbem python-roman python-serial python-service-identity python-six python-tk \
  python-twisted-bin python-twisted-core python-twisted-web python-zope.interface tcpd tk8.6-blt2.5 tzdata \
  x11-common



COPY  lighttpd.conf  /etc/lighttpd/lighttpd.conf
COPY lxiserver /etc/init.d/ 

#COPY lenovo-uus_1.0.0ubuntu1_all.deb .
#RUN mkdir -p extract/DEBIAN

#RUN dpkg-deb -x lenovo-uus_1.0.0ubuntu1_all.deb extract/
#RUN apt install -y -f 

COPY supervisord.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/supervisord.sh

#COPY nginx /etc/nginx/

RUN mkdir -p /opt/lenovo/UnifiedService
WORKDIR /opt/lenovo/UnifiedService
ADD . /opt/lenovo/UnifiedService
EXPOSE 80
CMD ["sh","/usr/local/bin/supervisord.sh"]

