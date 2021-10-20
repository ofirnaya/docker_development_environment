From centos:centos7

LABEL MAINTAINER="Ofir Ofri"

ADD example_apps.tar /root/

ENV container=docker \
JAVA_HONE=/usr/lib/jvm/java-11-openjdk-11.0.12.0.7-0.el7_9.x86_64

ARG SPARK_VERSION=3.1.2 \
VSCODE="https://download-cdn.jetbrains.com/idea/ideaIC-2021.2.3.tar.gz" \
HADOOP_USER_NAME=hdfs && \
CODE_SERVER_VERSION=3.12.0

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
yum install -y wget sudo python3 java-11-openjdk java-11-openjdk-devel nc git && \
echo "root" | sudo passwd --stdin root && \
useradd -m developer && \
usermod -a -G wheel developer && \
echo "developer" | passwd --stdin developer && \
sed -i 's/%wheel\tALL=(ALL)\tALL/# %wheel\tALL=(ALL)\tALL/g' /etc/sudoers && \
sed -i 's/# %wheel\tALL=(ALL)\tNOPASSWD: ALL/%wheel\tALL=(ALL)\tNOPASSWD: ALL/g' /etc/sudoers && \
cp -r /root/IdeaProjects /home/developer/ && \
cp -r /root/example_notebook.ipynb /home/developer/ && \
mkdir -p /home/developer/.local/lib /home/developer/.local/bin && \
curl -fL https://github.com/cdr/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz | tar -C /home/developer/.local/lib -xz && \
mv /home/developer/.local/lib/code-server-${CODE_SERVER_VERSION}-linux-amd64 /home/developer/.local/lib/code-server-${CODE_SERVER_VERSION} && \
ln -s /home/developer/.local/lib/code-server-${CODE_SERVER_VERSION}/bin/code-server /home/developer/.local/bin/code-server && \
pip3 install pyspark==${SPARK_VERSION} && \
echo "#!/bin/bash" > /startup.sh && \
echo "" >> /startup.sh && \
echo "sudo -u developer /home/developer/.local/bin/code-server" >> /startup.sh && \
echo "" >> /etc/bashrc && \
echo "# Added for image" >> /etc/bashrc && \
echo "export HADOOP_USER_NAME=${HADOOP_USER_NAME}" >> /etc/bashrc && \
mkdir -p /home/developer/.config/code-server && \
echo "bind-addr: 0.0.0.0:8080" > /home/developer/.config/code-server/config.yaml && \
echo "auth: password" >> /home/developer/.config/code-server/config.yaml && \
echo "password: developer" >> /home/developer/.config/code-server/config.yaml && \
echo "cert: false" >> /home/developer/.config/code-server/config.yaml && \
chmod +x /startup.sh && \
chown -R developer:developer /home/developer && \
yum clean all && \
rm -rf /var/cache/yum




EXPOSE 22 8888

ENTRYPOINT ["/startup.sh"]

# To run it: docker run -d -p 22022:22 --name dev_env -it ofrir119/developer_env:idea2021.1.1_spark2.4.0
