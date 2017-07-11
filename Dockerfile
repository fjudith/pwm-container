FROM tomcat:jre8

MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

ENV VERSION=1.8.0-SNAPSHOT-2017-07-11T08:10:38Z
ENV MYSQL_DRIVER_VERSION=5.1.42
ENV POSTGRES_DRIVER_VERSION=42.1.1
ENV MONGODB_DRIVER_VERSION=3.4.2
ENV MARIADB_DRIVER_VERSION=2.0.3

ENV PWM_HOME=${CATALINA_HOME}/webapps/pwm
ENV PWM_APPLICATIONPATH=/usr/share/pwm


# Install additional packages
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wget unzip xmlstarlet

# Create configuration directory

RUN mkdir -p $PWM_APPLICATIONPATH

# Create pwm user
RUN groupadd --system --gid 1234 pwm && \
	useradd --system --create-home --shell /bin/bash --gid 1234 --uid 1234 pwm

# Download & deploy pwm.war
RUN cd /tmp && \
    wget https://www.pwm-project.org/artifacts/pwm/pwm-${VERSION}-pwm-bundle.zip && \
    unzip ${VERSION}.zip -d /tmp/pwm && \
    unzip /tmp/pwm/pwm.war -d  ${PWM_HOME} && \
    chmod a+x ${PWM_HOME}/WEB-INF/command.sh

# Download database drivers
RUN cd ${CATALINA_HOME}/lib && \
    curl -O https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar && \
    curl -O https://jdbc.postgresql.org/download/postgresql-${POSTGRES_DRIVER_VERSION}.jar && \
    curl -O https://oss.sonatype.org/content/repositories/releases/org/mongodb/mongo-java-driver/${MONGODB_DRIVER_VERSION}/mongo-java-driver-${MONGODB_DRIVER_VERSION}.jar &&
    curl -O https://downloads.mariadb.com/Connectors/java/connector-java-${MARIADB_DRIVER_VERSION}/mariadb-java-client-${MARIADB_DRIVER_VERSION}.jar

# Update server.xml to set pwm webapp to root
RUN cd $CATALINA_HOME && \
    xmlstarlet ed \
    -P -S -L \
    -i '/Server/Service/Engine/Host/Valve' -t 'elem' -n 'Context' \
    -i '/Server/Service/Engine/Host/Context' -t 'attr' -n 'path' -v '/' \
    -i '/Server/Service/Engine/Host/Context[@path="/"]' -t 'attr' -n 'docBase' -v 'pwm' \
    -s '/Server/Service/Engine/Host/Context[@path="/"]' -t 'elem' -n 'WatchedResource' -v 'WEB-INF/web.xml' \
    -i '/Server/Service/Engine/Host/Valve' -t 'elem' -n 'Context' \
    -i '/Server/Service/Engine/Host/Context[not(@path="/")]' -t 'attr' -n 'path' -v '/ROOT' \
    -s '/Server/Service/Engine/Host/Context[@path="/ROOT"]' -t 'attr' -n 'docBase' -v 'ROOT' \
    -s '/Server/Service/Engine/Host/Context[@path="/ROOT"]' -t 'elem' -n 'WatchedResource' -v 'WEB-INF/web.xml' \
    conf/server.xml

# Cleanup
RUN rm -rf \
    /var/lib/apt/lists/* \
    /tmp/${VERSION}.zip \
    /tmp/pwm

# Deploy EntryPoint
COPY docker-entrypoint.sh /sbin/
RUN chmod +x /sbin/docker-entrypoint.sh

# Fix permissions
#RUN chown -R pwm. $CATALINA_HOME
#RUN chown -R pwm. $PWM_APPLICATIONPATH

#USER pwm

WORKDIR $CATALINA_HOME

EXPOSE 8080

#ENTRYPOINT ["/sbin/docker-entrypoint.sh"]

CMD ["catalina.sh", "run"]