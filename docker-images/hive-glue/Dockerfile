FROM maven:3.6-openjdk-8 AS build

RUN git clone --progress https://github.com/apache/hive.git /hive

ENV GIT_REF 93163cb8d2c0e9ce4f0bb74817b801e8e184a85c
ENV HIVE_VERSION 2.3.6
ENV HADOOP_DEP "<dependency><groupId>org.apache.hadoop</groupId><artifactId>hadoop-common</artifactId><version>\${hadoop.version}</version><scope>provided</scope></dependency>"

WORKDIR /hive

RUN wget https://issues.apache.org/jira/secure/attachment/12958418/HIVE-12679.branch-2.3.patch; \
    git checkout ${GIT_REF}; \
    git apply -p0 < HIVE-12679.branch-2.3.patch 2> /dev/null

RUN mvn clean install -DskipTests -Pdist

RUN mkdir -p /opt/hive; \
    mv /hive/packaging/target/apache-hive-2.3.6-SNAPSHOT-bin/apache-hive-2.3.6-SNAPSHOT-bin/* /opt/hive

RUN git clone https://github.com/awslabs/aws-glue-data-catalog-client-for-apache-hive-metastore.git /opt/aws-glue-datacatalog; \
    cd /opt/aws-glue-datacatalog; \
    sed -ri "s|<(hive2.version)>.+</(\1)>|<\1>${HIVE_VERSION}-SNAPSHOT</\1>|" pom.xml; \
    sed -i 's|org.spark-project.hive|org.apache.hive|' */pom.xml */*/pom.xml; \
    sed -ri "s|<dependencies>|<dependencies>$HADOOP_DEP|g" shims/spark-hive-shims/pom.xml; \
    mvn clean package -DskipTests -pl '!aws-glue-datacatalog-spark-client'/; \
    cp aws-glue-datacatalog-hive2-client/target/*.jar aws-glue-datacatalog-client-common/target/*.jar /opt/hive/lib

FROM hadoop-base:2.10.1 AS dist

ENV HIVE_VERSION 2.3.6
ENV HIVE_HOME /opt/hive
ENV HIVE_CONF_DIR ${HIVE_HOME}/conf
ENV PATH "${PATH}:${HIVE_HOME}/bin"
ENV HADOOP_CLASSPATH "${HADOOP_CLASSPATH}:${HIVE_HOME}/lib/*"

COPY --from=build /opt/hive /opt/hive

ENV GUAVA_VERSION 11.0.2

RUN rm ${HIVE_HOME}/lib/guava*; \
    wget https://repo1.maven.org/maven2/com/google/guava/guava/${GUAVA_VERSION}/guava-${GUAVA_VERSION}.jar -O ${HIVE_HOME}/lib/guava-${GUAVA_VERSION}.jar

ADD entrypoint.sh /entrypoint.sh

RUN mkdir -p ${HIVE_CONF_DIR}; \
    mkdir -p ${HIVE_HOME}/var/log; \
    chmod +x /entrypoint.sh

WORKDIR ${HIVE_HOME}

ENTRYPOINT [ "/entrypoint.sh" ]
