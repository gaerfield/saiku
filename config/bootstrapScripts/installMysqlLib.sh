#!/bin/bash

MYSQL_VERSION=8.0.13
JDBC_DOWNLOAD_URL=https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_VERSION}.zip

curl -Lsf -o /tmp/jdbc.zip $JDBC_DOWNLOAD_URL
unzip /tmp/jdbc.zip -d /tmp
mv /tmp/mysql-connector-java-${MYSQL_VERSION}/mysql-connector-java-${MYSQL_VERSION}.jar /saiku/tomcat/webapps/saiku/WEB-INF/lib/
rm -rf /tmp/mysql-connector-java-${MYSQL_VERSION} /tmp/jdbc.zip
