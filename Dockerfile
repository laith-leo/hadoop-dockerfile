FROM ubuntu:20.04
WORKDIR /opt
LABEL Author="Laith Leo Alobaidy, laith@laith.info"

RUN apt update -y && apt upgrade -y \
  && apt install -y openjdk-8-jdk \
    && apt install -y nmap \
    && apt install curl -y \
  && apt install -y tzdata \
    && apt install -y openssh-server

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
RUN  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys
RUN  chmod 0600 ~/.ssh/authorized_keys
#THIS CAN BE REPLACED WITH: RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

RUN export DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/New_York /etc/localtime
RUN dpkg-reconfigure --frontend noninteractive tzdata

EXPOSE 22
EXPOSE 8088
EXPOSE 9000
RUN  service ssh start && bash
#RUN ssh -o StrictHostKeyChecking=no -l "root" "localhost"

 RUN  curl https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz --output /opt/hadoop-3.3.1.tar.gz --silent && tar -xzvf /opt/hadoop-3.3.1.tar.gz

RUN echo '<configuration><property><name>fs.defaultFS</name><value>hdfs://localhost:9000</value></property></configuration>' > /opt/hadoop-3.3.1/etc/hadoop/core-site.xml
RUN echo '<configuration><property><name>dfs.replication</name><value>1</value></property></configuration>' > /opt/hadoop-3.3.1/etc/hadoop/core-site.xml
#RUN ssh localhost

RUN export HIVE_HOME=/opt/apache-hive-3.1.2-bin/
RUN export HADOOP_HOME=/opt/hadoop-3.3.1/
RUN export HDFS_NAMENODE_USER="root"
RUN export HDFS_DATANODE_USER="root"
RUN export HDFS_SECONDARYNAMENODE_USER="root"
RUN export YARN_RESOURCEMANAGER_USER="root"
RUN export YARN_NODEMANAGER_USER="root"
RUN export PATH=$PATH:/opt/hadoop-3.3.1/bin
RUN export JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:bin/java::") >> /opt/hadoop-3.3.1/etc/hadoop/hadoop-env.sh

RUN /opt/hadoop-3.3.1/bin/hdfs namenode -format
 RUN  /opt/hadoop-3.3.1/sbin/start-dfs.sh
 RUN  /opt/hadoop-3.3.1/sbin/start-yarn.sh
