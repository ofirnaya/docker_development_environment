From centos:centos7

LABEL MAINTAINER="Ofir Ofri"

ADD example_apps.tar /root/

ENV container=docker \
JAVA_HONE=/usr/lib/jvm/java-11-openjdk-11.0.12.0.7-0.el7_9.x86_64

ARG SPARK_VERSION=3.1.2 \
INTELLIJ_LINK="https://download-cdn.jetbrains.com/idea/ideaIC-2021.2.3.tar.gz" \
HADOOP_USER_NAME=hdfs

RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == \
systemd-tmpfiles-setup.service ] || rm -f $i; done) && \
rm -f /lib/systemd/system/multi-user.target.wants/* && \
rm -f /etc/systemd/system/*.wants/* && \
rm -f /lib/systemd/system/local-fs.target.wants/* && \
rm -f /lib/systemd/system/sockets.target.wants/*udev* && \
rm -f /lib/systemd/system/sockets.target.wants/*initctl* && \
rm -f /lib/systemd/system/basic.target.wants/* &&\
rm -f /lib/systemd/system/anaconda.target.wants/* && \
yum -y update && \
yum install -y epel-release && \
yum -y install https://packages.endpoint.com/rhel/7/os/x86_64/endpoint-repo-1.9-1.x86_64.rpm && \
yum install -y openssh-server openssh-client xorg-x11* wget sudo python3 java-11-openjdk java-11-openjdk-devel nc git && \
sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/g' /etc/ssh/sshd_config && \
sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/g' /etc/ssh/sshd_config && \
systemctl enable sshd && \
echo "root" | sudo passwd --stdin root && \
useradd -m developer && \
usermod -a -G wheel developer && \
echo "developer" | passwd --stdin developer && \
sed -i 's/%wheel\tALL=(ALL)\tALL/# %wheel\tALL=(ALL)\tALL/g' /etc/sudoers && \
sed -i 's/# %wheel\tALL=(ALL)\tNOPASSWD: ALL/%wheel\tALL=(ALL)\tNOPASSWD: ALL/g' /etc/sudoers && \
cp -r /root/.jupyter /home/developer/ && \
cp -r /root/IdeaProjects /home/developer/ && \
cp -r /root/example_notebook.ipynb /home/developer/ && \
chown -R developer:developer /home/developer && \
mkdir -p /opt/jetbrain && \
wget "${INTELLIJ_LINK}" -O /opt/jetbrain/idea.tar.gz && \
tar xzvf /opt/jetbrain/idea.tar.gz -C /opt/jetbrain/ && \
mv /opt/jetbrain/idea-IC* /opt/jetbrain/idea && \
rm /opt/jetbrain/idea.tar.gz && \
echo '#!/bin/sh' | tee /usr/bin/idea && \
echo '' | tee -a /usr/bin/idea && \
echo 'export PYSPARK_PYTHON=python3' | tee -a /usr/bin/idea && \
echo 'export PYSPARK_DRIVER_PYTHON=python3' | tee -a /usr/bin/idea && \
echo '' | tee -a /usr/bin/idea && \
echo 'nohup /opt/jetbrain/idea/bin/idea.sh > /tmp/$(whoami)_idea.log &' | tee -a /usr/bin/idea && \
chmod +x /usr/bin/idea && \
chmod +x /opt/jetbrain/idea/bin/idea.sh && \
pip3 install pyspark==${SPARK_VERSION} jupyter && \
pip3 install --upgrade jedi==0.17.2 && \
ssh-keygen -A && \
echo "#!/bin/bash" > /startup.sh && \
echo "" >> /startup.sh && \
echo "/usr/sbin/sshd" >> /startup.sh && \
echo "/root/start_jupyter.sh" >> /startup.sh && \
echo "" >> /etc/bashrc && \
echo "# Added for image" >> /etc/bashrc && \
echo "export HADOOP_USER_NAME=${HADOOP_USER_NAME}" >> /etc/bashrc && \
chmod +x /startup.sh && \
yum clean all && \
rm -rf /var/cache/yum




EXPOSE 22 8888

ENTRYPOINT ["/startup.sh"]

# To run it: docker run -d -p 22022:22 --name dev_env -it ofrir119/developer_env:idea2021.1.1_spark2.4.0
