FROM regreb/bibutils as bibutils
FROM tomcat:9.0.35-jdk11
# Bind paths /root/.mycore/mir/
EXPOSE 8080
EXPOSE 8009
USER root
WORKDIR /opt/ubo
WORKDIR /usr/local/tomcat/
ARG PACKET_SIZE="65536"
ARG MIR_VERSION="2020.06.0-SNAPSHOT"
ENV JAVA_OPTS="-Xmx1g -Xms1g"
ENV APP_CONTEXT="mir"
COPY docker-entrypoint.sh /usr/local/bin/mir.sh
COPY sample-files /opt/mir/sample-files
COPY sample-users /opt/mir/sample-users
COPY load-sample-files.txt /opt/mir/load-sample-files.txt
COPY load-sample-users.txt /opt/mir/load-sample-users.txt
COPY --from=bibutils --chown=root:root /usr/local/bin/* /usr/local/bin/
RUN ["chmod", "+x", "/usr/local/bin/mir.sh"]
RUN rm -rf /usr/local/tomcat/webapps/* && \
    sed -ri "s/<\/Service>/<Connector protocol=\"AJP\/1.3\" packetSize=\"$PACKET_SIZE\" tomcatAuthentication=\"false\" scheme=\"https\" secretRequired=\"false\" allowedRequestAttributesPattern=\".*\" encodedSolidusHandling=\"decode\" address=\"0.0.0.0\" port=\"8009\" redirectPort=\"8443\" \/>&/g" /usr/local/tomcat/conf/server.xml && \
    curl -L "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=org.mycore.mir&a=mir-webapp&v=$MIR_VERSION&e=war">/opt/mir/mir.war && \
    curl -L "https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=org.mycore.mir&a=mir-cli&v=$MIR_VERSION&e=zip">/opt/mir/mir-cli.zip && \
    cd /opt/mir/ && \
    unzip mir-cli.zip && \
    mv "mir-cli-$MIR_VERSION" "mir"
CMD ["bash", "/usr/local/bin/mir.sh"]
