
FROM tomcat:9-jre8-alpine

LABEL maintainer="Florian JUDITH <florian.judith.b@gmail.com>"
ARG VERSION=1.9.1
ENV MYSQL_DRIVER_VERSION=8.0.15
ENV POSTGRES_DRIVER_VERSION=42.2.5
ENV MONGODB_DRIVER_VERSION=3.9.1
ENV MARIADB_DRIVER_VERSION=2.4.0

ENV PWM_HOME=${CATALINA_HOME}/webapps/pwm
ENV PWM_APPLICATIONPATH=/usr/share/pwm

# Create pwm user
RUN addgroup -g 1234 pwm && \
    adduser -D -u 1234 -G pwm pwm

RUN mkdir -p $PWM_APPLICATIONPATH

# Install additional packages
RUN apk add --no-cache openjdk8 maven xmlstarlet curl wget unzip && \
    cd /tmp && \
    wget https://www.pwm-project.org/artifacts/pwm/release/v${VERSION}/pwm-${VERSION}.war && \
    unzip /tmp/pwm-${VERSION}.war -d  ${PWM_HOME} && \
    rm -f /tmp/pwm-${VERSION}.war && \
    chmod a+x ${PWM_HOME}/WEB-INF/command.sh && \
    apk del --purge openjdk8 maven git patch

# Download database drivers
RUN cd ${CATALINA_HOME}/lib && \
    curl -O https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar && \
    curl -O https://jdbc.postgresql.org/download/postgresql-${POSTGRES_DRIVER_VERSION}.jar && \
    curl -L -O https://oss.sonatype.org/content/repositories/releases/org/mongodb/mongo-java-driver/${MONGODB_DRIVER_VERSION}/mongo-java-driver-${MONGODB_DRIVER_VERSION}.jar && \
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

# Deploy EntryPoint
COPY docker-entrypoint.sh /sbin/
RUN chmod +x /sbin/docker-entrypoint.sh

# Fix permissions
RUN chown -R pwm. $CATALINA_HOME
RUN chown -R pwm. $PWM_APPLICATIONPATH

USER pwm

WORKDIR $CATALINA_HOME

EXPOSE 8080

#ENTRYPOINT ["/sbin/docker-entrypoint.sh"]

CMD ["catalina.sh", "run"]
