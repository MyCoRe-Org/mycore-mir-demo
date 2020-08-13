#!/usr/bin/bash
set -e

echo "MIR Starter Script"
sleep 5 # wait for database (TODO: replace with wait-for-it)
MCR_HOME=/root/.mycore/${APP_CONTEXT}/

function downloadDriver {
  FILENAME=$(basename $1)
  if [[ ! -f "${MCR_HOME}lib/$FILENAME" ]]
  then
    curl -o "${MCR_HOME}lib/$FILENAME" "$1"
  fi
  # no copy needed anymore
  # if [[ ! -f "/opt/mir/target/${FILENAME}" ]]
  # then
  #  cp "${MCR_HOME}lib/$FILENAME" "/opt/mir/target/${FILENAME}"
  # fi
}

function setUpMyCoRe {
    sed -ri "s/(-DMCR.AppName=).+( \\\\)/\1${APP_CONTEXT}\2/" /opt/mir/mir/bin/mir.sh
    /opt/mir/mir/bin/mir.sh create configuration directory

    sed -ri "s/(name=\"javax.persistence.jdbc.user\" value=\").*(\")/\1${JDBC_NAME}\2/" "${MCR_HOME}resources/META-INF/persistence.xml"
    sed -ri "s/(name=\"javax.persistence.jdbc.password\" value=\").*(\")/\1${JDBC_PASSWORD}\2/" "${MCR_HOME}resources/META-INF/persistence.xml"
    sed -ri "s/(name=\"javax.persistence.jdbc.driver\" value=\").*(\")/\1${JDBC_DRIVER}\2/" "${MCR_HOME}resources/META-INF/persistence.xml"
    sed -ri "s/(name=\"javax.persistence.jdbc.url\" value=\").*(\")/\1${JDBC_URL}\2/" "${MCR_HOME}resources/META-INF/persistence.xml"
    sed -ri "s/(name=\"hibernate.hbm2ddl.auto\" value=\").*(\")/\1update\2/" "${MCR_HOME}resources/META-INF/persistence.xml"
    sed -ri "s/<mapping-file>META-INF\/mycore-viewer-mappings.xml<\/mapping-file>/&<mapping-file>META-INF\/mir-module-mappings.xml<\/mapping-file>/" "${MCR_HOME}resources/META-INF/persistence.xml"
    sed -ri "s/(<\/properties>)/<property name=\"hibernate\.connection\.provider_class\" value=\"org\.hibernate\.connection\.C3P0ConnectionProvider\" \/>\n<property name=\"hibernate\.c3p0\.min_size\" value=\"2\" \/>\n<property name=\"hibernate\.c3p0\.max_size\" value=\"50\" \/>\n<property name=\"hibernate\.c3p0\.acquire_increment\" value=\"2\" \/>\n<property name=\"hibernate\.c3p0\.max_statements\" value=\"30\" \/>\n<property name=\"hibernate\.c3p0\.timeout\" value=\"1800\" \/>\n\1/" "${MCR_HOME}resources/META-INF/persistence.xml"
    sed -ri "s/#?(MCR\.Solr\.ServerURL=).+/\1${SOLR_URL}/" "${MCR_HOME}mycore.properties"
    sed -ri "s/#?(MCR\.Solr\.Core\.main\.Name=).+/\1${SOLR_CORE}/" "${MCR_HOME}mycore.properties"
    mkdir -p "${MCR_HOME}lib"

    case $JDBC_DRIVER in
      org.postgresql.Driver) downloadDriver "https://jdbc.postgresql.org/download/postgresql-42.2.9.jar";;
      org.mariadb.jdbc.Driver) downloadDriver "https://repo.maven.apache.org/maven2/org/mariadb/jdbc/mariadb-java-client/2.5.4/mariadb-java-client-2.5.4.jar";;
      org.hsqldb.jdbcDriver) downloadDriver "https://repo.maven.apache.org/maven2/org/hsqldb/hsqldb/2.5.0/hsqldb-2.5.0.jar";;
      org.h2.Driver) downloadDriver "https://repo.maven.apache.org/maven2/com/h2database/h2/1.4.200/h2-1.4.200.jar";;
      com.mysql.jdbc.Driver) downloadDriver "https://repo.maven.apache.org/maven2/mysql/mysql-connector-java/8.0.19/mysql-connector-java-8.0.19.jar";;
    esac

    downloadDriver https://repo1.maven.org/maven2/org/hibernate/hibernate-c3p0/5.3.9.Final/hibernate-c3p0-5.3.9.Final.jar
    downloadDriver https://repo1.maven.org/maven2/com/mchange/c3p0/0.9.5.2/c3p0-0.9.5.2.jar
    downloadDriver https://repo1.maven.org/maven2/com/mchange/mchange-commons-java/0.2.15/mchange-commons-java-0.2.15.jar

    /opt/mir/mir/bin/setup.sh
    /opt/mir/mir/bin/mir.sh "process /opt/mir/load-sample-files.txt"
    /opt/mir/mir/bin/mir.sh "process /opt/mir/load-sample-users.txt"

}

[ "$(ls -A "$MCR_HOME")" ] && echo "MyCoRe-Home is not empty" || setUpMyCoRe

rm -rf /usr/local/tomcat/webapps/*
cp /opt/mir/mir.war "/usr/local/tomcat/webapps/${APP_CONTEXT}.war"
catalina.sh run
