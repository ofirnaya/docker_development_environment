From centos:centos7

ADD example_apps.tar /root/

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
yum install -y openssh-server openssh-client xorg-x11* wget sudo python3 java-1.8.0-openjdk java-1.8.0-openjdk-devel nc git fish && \
sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/g' /etc/ssh/sshd_config && \
sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/g' /etc/ssh/sshd_config && \
systemctl enable sshd && \
echo "root" | sudo passwd --stdin root && \
useradd -m developer && \
usermod -a -G wheel developer && \
echo "developer" | passwd --stdin developer && \
sed -i 's/%wheel  ALL=(ALL)       ALL/# %wheel  ALL=(ALL)       ALL/g' /etc/sudoers && \
sed -i 's/# %wheel        ALL=(ALL)       NOPASSWD: ALL/%wheel        ALL=(ALL)       NOPASSWD: ALL/g' /etc/sudoers && \
cp -r /root/.jupyter /home/developer/ && \
cp -r /root/IdeaProjects /home/developer/ && \
cp -r /root/example_notebook.ipynb /home/developer/ && \
cp -r /root/start_jupyter.sh /home/developer/ && \
chown -R developer:developer /home/developer && \
alias ll='ls -alF' && \
echo -n 'developer' | chsh -s /usr/bin/fish && \
mkdir -p /opt/jetbrain && \
wget https://download.jetbrains.com/idea/ideaIC-2021.1.1.tar.gz?_ga=2.215325460.2032521094.1620555958-942613243.1603954277 -O /opt/jetbrain/idea.tar.gz && \
tar xzvf /opt/jetbrain/idea.tar.gz -C /opt/jetbrain/ && \
mv /opt/jetbrain/idea-IC* /opt/jetbrain/idea && \
echo '#!/bin/sh' | tee /usr/bin/idea && \
echo '' | tee -a /usr/bin/idea && \
echo 'export PYSPARK_PYTHON=python3' | tee -a /usr/bin/idea && \
echo 'export PYSPARK_DRIVER_PYTHON=python3' | tee -a /usr/bin/idea && \
echo '' | tee -a /usr/bin/idea && \
echo 'nohup /opt/jetbrain/idea/bin/idea.sh > /tmp/idea.log &' | tee -a /usr/bin/idea && \
chmod +x /usr/bin/idea && \
chmod +x /opt/jetbrain/idea/bin/idea.sh && \
echo '#!/bin/sh' | tee /root/start_jupyter.sh && \
echo '' | tee -a /root/start_jupyter.sh && \
echo 'export PYSPARK_PYTHON=python3' | tee -a /root/start_jupyter.sh && \
echo 'export PYSPARK_DRIVER_PYTHON=python3' | tee -a /root/start_jupyter.sh && \
echo '' | tee -a /root/start_jupyter.sh && \
echo 'jupyter notebook --allow-root' | tee -a /root/start_jupyter.sh && \
chmod +x /root/start_jupyter.sh && \
pip3 install pyspark==2.4.0 pyspark-stubs==2.4.0 jupyter

ENV container=docker \
JAVA_HONE=/usr/lib/jvm/java-1.8.0


EXPOSE 22 8888

ENTRYPOINT ["/usr/sbin/init"]
#ENTRYPOINT ["/home/developer/start_jupyter.sh"]

# To run it: docker run -d -p 22:22 --privileged=true --name dev_env -it ofrir119/developer_env:idea2021.1.1_spark2.4.0
