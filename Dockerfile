FROM centos:centos7
MAINTAINER Marcin Ryzycki marcin@m12.io, Przemyslaw Ozgo linux@ozgo.info

# - Install basic packages (e.g. python-setuptools is required to have python's easy_install)
# - Install net-tools, small package with basic networking tools (e.g. netstat)
# - Install inotify, needed to automate daemon restarts after config file changes
# - Install supervisord (via python's easy_install - as it has the newest 3.x version)
# - Install yum-utils so we have yum-config-manager tool available
RUN \
  yum update -y && \
  yum install -y epel-release && \
  yum install -y net-tools python-setuptools python-pip hostname inotify-tools yum-utils && \
  yum clean all && \
  easy_install supervisor

# Add supervisord conf, bootstrap.sh files
ADD container-files /

RUN pip install --upgrade pip
RUN yum install -y tar python-devel libxml2 libxml2-dev libxslt* zlib openssl 
RUN yum install -y gcc libffi-devel python-devel openssl-devel 
# Add crawler env
RUN \
  cd /config/crawl/ && \
  pip install -r manager-requirement.txt && \
  pip install -r agent-requirement.txt

RUN \
   yum install -y git && cd /opt/ && \
   git clone --recursive git://github.com/ariya/phantomjs.git && \
   cd phantomjs && ./build.py && \
   chmod a+x ./bin/phantomjs && \
   cp ./bin/phantomjs /usr/bin/ && \
   rm -rf /opt/phantomjs

VOLUME ["/data"]

ENTRYPOINT ["/config/bootstrap.sh"]
