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

# Add crawler env
RUN cd /usr/bin && \
    wget http://soft.6eimg.com/phantomjs && \
    chmod a+x phantomjs

RUN \
  cd /config/crawl/ && \
  pip install -r manager-requirement.txt && \
  pip install -r agent-agent-requirement.txt

VOLUME ["/data"]

ENTRYPOINT ["/config/bootstrap.sh"]
