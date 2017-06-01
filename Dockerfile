##ELK services running in single container
##Package version
##elasticsearch-5.4.0, kibana-5.4.0, logstash-5.4.0 & JDK-8u77
 
#Base CENTOS 7 image
FROM    centos:7
 
#Adding Packages & Files
ADD     packages/*  /
ADD     files/* /
 
#Proxy Declaration
#ENV  http_proxy="x.example.com:9999"
#ENV  https_proxy="x.example.com:9999"
 
#Env Variables declaration
ENV     JAVA_HOME=/usr/bin/java
ENV     JAVACMD=/usr/bin/java
 
 
#Dependencies and repo packages installation
RUN     yum install telnet which -y && \
        yum clean all && \
        rpm -ivh /epel-release-latest-7.noarch.rpm && \
        yum -y install python-pip && \
        yum clean all && \
        pip install supervisor && \
        pip install --upgrade pip && \
        chmod -R 777 elasticsearch-5.4.0/ && \
        chmod -R 777 kibana-5.4.0-linux-x86_64/ && \
        chmod -R 777 logstash-5.4.0/ && \
        cd / && \
        rpm -ivh jdk-8u77-linux-x64.rpm && \
 
#ELASTIC-SEARCH Configuration
 
        sed -i -e "s/#network.host: 192.168.0.1/network.host: 0.0.0.0/g" /elasticsearch-5.4.0/config/elasticsearch.yml && \
        sed -i -e "s/#http.port: 9200/http.port: 9200/g" /elasticsearch-5.4.0/config/elasticsearch.yml
 
#LOGSTASH Configuration
RUN     export JAVACMD=`which java` && \
 
#KIBANA Configuration
        sed -i -e "s/#server.port: 5601/server.port: 5601/g" /kibana-5.4.0-linux-x86_64/config/kibana.yml && \
        sed -i -e 's/#server.host: "localhost"/server.host: "0.0.0.0"/g' /kibana-5.4.0-linux-x86_64/config/kibana.yml && \
 
 
#SUPERVISOR an init/systemd like light weight process controller
        mkdir -p /etc/supervisor/conf.d/ && \
        cp /supervisord.conf /etc/supervisor/conf.d/supervisord.conf && \
 
#Cleaning trivial files and packages
        rm -rf /jdk-8u77-linux-x64.rpm && \
        rm -rf /epel-release-latest-7.noarch.rpm && \
 
#CHANGING SUPERVIOSRD PERMISSION
        chmod 777 /usr/bin/supervisord
 
 
#TCP ports elastic-search 9200, Log-stash 5044 & Kibana 5601
EXPOSE 9200 5601 5044
 
#ELK service execution using supervisord
CMD     /usr/bin/supervisord
