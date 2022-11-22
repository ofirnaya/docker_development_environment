From ubuntu:kinetic

LABEL MAINTAINER="Ofir Ofri"

ENV container=docker \
JAVA_HONE=/usr/lib/jvm/java-11-openjdk-amd64

ARG SPARK_VERSION=3.3.1 \
SPARK_JARS_DIR="/usr/local/lib/python3.10/dist-packages/pyspark/jars"

ADD example_apps.tar /root/

RUN apt-get update -y && \
apt-get install -y openjdk-11-jdk openssh-server wget sudo git vim python3-pip curl unzip maven && \
sed -i 's/#X11DisplayOffset 10/X11DisplayOffset 10/g' /etc/ssh/sshd_config && \
sed -i 's/#X11UseLocalhost yes/X11UseLocalhost no/g' /etc/ssh/sshd_config && \
echo "root:root" | chpasswd && \
useradd -s /bin/bash -m developer && \
usermod -aG sudo developer && \
echo "developer:developer" | chpasswd && \
sed -i 's/%sudo\tALL=(ALL:ALL) ALL/%sudo\tALL=(ALL) NOPASSWD:ALL/g' /etc/sudoers && \
rm -rf /var/cache/apt/archives /var/lib/apt/lists/*

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
unzip awscliv2.zip && \
sudo ./aws/install && \
rm awscliv2.zip && \
rm -rf aws

RUN pip install --no-cache-dir pyspark==${SPARK_VERSION} ipykernel && \
pip install --no-cache-dir --upgrade jedi==0.17.2 && \
pip install --no-cache-dir kafka-python && \
wget "https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.1/hadoop-aws-3.3.1.jar" -O ${SPARK_JARS_DIR}/hadoop-aws-3.3.1.jar && \
wget "https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.11.901/aws-java-sdk-bundle-1.11.901.jar" -O ${SPARK_JARS_DIR}/aws-java-sdk-bundle-1.11.901.jar && \
ssh-keygen -A && \
echo "export PYSPARK_PYTHON=python3" >> /etc/bashrc && \
echo "export PYSPARK_DRIVER_PYTHON=python3" >> /etc/bashrc && \
echo "export HADOOP_CONF_DIR=/etc/hadoop/conf" >> /etc/bashrc && \
echo "export PYSPARK_PYTHON=python3" >> /home/developer/.bashrc && \
echo "export PYSPARK_DRIVER_PYTHON=python3" >> /home/developer/.bashrc && \
echo "export HADOOP_CONF_DIR=/etc/hadoop/conf" >> /home/developer/.bashrc && \
echo "#!/bin/bash" > /startup.sh && \
echo "" >> /startup.sh && \
echo "service ssh start" >> /startup.sh && \
echo "tail -f /dev/null" >> /startup.sh && \
echo "" >> /etc/bashrc && \
echo "# Added for image" >> /etc/bashrc && \
chmod +x /startup.sh


RUN cp -r /root/projects /home/developer/ && \
cp -r /root/notebooks /home/developer/ && \
mkdir -p /etc/hadoop/conf && \
cp /root/core-site.xml /etc/hadoop/conf/ && \
chown -R developer:developer /home/developer

EXPOSE 22 8888

ENTRYPOINT ["/startup.sh"]

# To run it: docker run -d -p 22022:22 --name dev_env -it ofrir119/developer_env:idea2021.1.1_spark2.4.0
