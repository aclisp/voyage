FROM 61.160.36.122:8080/java-sdk:1.8.0-77

ENV HADOOP_VERSION 2.7.2

COPY hadoop-$HADOOP_VERSION.tar.gz /opt/
RUN tar -xzf "/opt/hadoop-$HADOOP_VERSION.tar.gz" -C /opt \
  && rm "/opt/hadoop-$HADOOP_VERSION.tar.gz" \
  && mv /opt/hadoop-$HADOOP_VERSION /opt/hadoop

ENV HADOOP_PREFIX /opt/hadoop
ENV PATH $HADOOP_PREFIX/bin:$PATH
