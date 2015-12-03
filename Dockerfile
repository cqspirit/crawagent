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
  
# install ssh server
# 安装openssh-server和sudo软件包，并且将sshd的UsePAM参数设置成no  
RUN yum install -y openssh-server sudo  
RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config  
   
# 添加测试用户admin，密码admin，并且将此用户添加到sudoers里  
RUN useradd admin  
RUN echo "admin:admin" | chpasswd  
RUN echo "admin   ALL=(ALL)       ALL" >> /etc/sudoers  
   
# 下面这两句比较特殊，在centos6上必须要有，否则创建出来的容器sshd不能登录  
RUN ssh-keygen -t dsa -f /etc/ssh/ssh_host_dsa_key  
RUN ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key  
   
# 启动sshd服务并且暴露22端口  
RUN mkdir /var/run/sshd  
EXPOSE 22  

# - install crawler env
RUN \
  yum groups mark install -y development && \
  yum install -y zlib-dev openssl-devel sqlite-devel bzip2-devel wget curl && \
  yum install -y xz-libs vim expect && \
  yum clean all
  
RUN \
  cd /tmp && \
  wget --no-check-certificate https://pypi.python.org/packages/source/s/setuptools/setuptools-1.4.2.tar.gz && \
  tar -xvf setuptools-1.4.2.tar.gz && \
  cd setuptools-1.4.2 && \
  python setup.py install
  
RUN \
  curl https://raw.githubusercontent.com/pypa/pip/master/contrib/get-pip.py | python - && \
  pip install virtualenv && \
  cd /config/crawler/  && \
  pip install -r manager-requirement.txt && \
  pip install -r agent-requirement.txt

# - RUN \
# -  cd /usr/bin/ && \ 
# -  wget http://soft.6estates.com/phantomjs && \
# -  chmod a+x phantomjs
#RUN \
#    yum install -y gcc gcc-c++ make flex bison gperf ruby  openssl-devel freetype-devel fontconfig-devel libicu-devel sqlite-devel libpng-devel libjpeg-devel && \
#    git clone --recursive git://github.com/ariya/phantomjs.git  && \
#    cd phantomjs  && \
#    ./build.py  && \
#    cp ./bin/phantomjs /usr/bin 

# env
ENV CRAW_USER  dc-agent
ENV CRAW_PW    'rawler@next'
RUN \
    useradd $CRAW_USER -M -p $CRAW_PW

# Add supervisord conf, bootstrap.sh files
ADD container-files /
# - add app path
# ADD /opt/crawl  /opt/crawl
ADD /public/log /tmp
# - add log path
VOLUME ["/data"]
VOLUME ["/opt/crawl", "/opt/crawl"] 

ENTRYPOINT ["/config/bootstrap.sh"]
