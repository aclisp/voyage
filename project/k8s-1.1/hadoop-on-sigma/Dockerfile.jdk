FROM 61.160.36.122:8080/lightvm:latest

ENV JDK_VERSION 8u77

COPY jdk-$JDK_VERSION-linux-x64.tar.gz /opt/
RUN tar -xzf "/opt/jdk-$JDK_VERSION-linux-x64.tar.gz" -C /opt \
  && rm "/opt/jdk-$JDK_VERSION-linux-x64.tar.gz"

ENV JAVA_HOME /opt/jdk1.8.0_77
ENV PATH $JAVA_HOME/bin:$PATH
