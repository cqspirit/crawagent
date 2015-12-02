FROM centos:centos7
MAINTAINER geyong geyong.cq@gmail.com

# - Install basic packages (e.g. python-setuptools is required to have python's easy_install)
# - Install net-tools, small package with basic networking tools (e.g. netstat)
# - Install inotify, needed to automate daemon restarts after config file changes
# - Install supervisord (via python's easy_install - as it has the newest 3.x version)
# - Install yum-utils so we have yum-config-manager tool available
RUN \
  yum update -y && \
  yum install -y epel-release && \
  yum install -y net-tools python-setuptools hostname inotify-tools yum-utils && \
  yum clean all && \
  easy_install supervisor
  
# - install crawler env
RUN \
  yum groupinstall -y development && \
  yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel wget curl && \
  yum install -y xz-libs vim expect && \
  yum clean all
  
# - RUN \
# -   cd /tmp && \
# -   wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz && \
# -   tar -xvf setuptools-1.4.2.tar.gz && \
# -   cd setuptools-1.4.2 && \
# -   python setup.py install && \
  
RUN \
  curl https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py | python - && \
  pip install virtualenv 
  
#RUN \
#  cd /usr/bin/ && \ 
#  wget http://soft.6estates.com/phantomjs && \
#  chmod a+x phantomjs
  

# Add supervisord conf, bootstrap.sh files
ADD container-files /

VOLUME ["/data"]

ENTRYPOINT ["/config/bootstrap.sh"]
