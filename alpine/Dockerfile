FROM docker.io/amd64/maven:3-openjdk-11 AS builder

ARG APP_VERSION

RUN apt-get update -y \
    && apt-get install -y --no-install-recommends \
        'git' \
    && git clone \
        -b "v$(echo ${APP_VERSION} | sed -E 's#\.#_#g')" \
        --single-branch https://github.com/pwm-project/pwm.git \
    && cd pwm/ \
    && mvn package -Dmaven.test.skip=true \
    && ls -l webapp/target/


##################################################

FROM docker.io/amd64/tomcat:9-jre8-alpine

ARG APP_VERSION

LABEL maintainer="Florian JUDITH <florian.judith.b@gmail.com>"

ENV MYSQL_DRIVER_VERSION=8.0.32 \
    POSTGRES_DRIVER_VERSION=42.6.0 \
    MONGODB_DRIVER_VERSION=3.9.1 \
    MARIADB_DRIVER_VERSION=3.1.3 \
    PWM_HOME=${CATALINA_HOME}/webapps/pwm \
    PWM_PATH=/usr/share/pwm

# Create pwm user
RUN addgroup -g 1234 pwm \
    && adduser -D -u 1234 -G pwm pwm

# Install additional packages
RUN mkdir -vp ${PWM_PATH} \
    && apk add --no-cache \
        'xmlstarlet' \
        'curl' \
        'unzip' \
    && cd ${CATALINA_HOME}/lib \
    && curl -O https://repo1.maven.org/maven2/mysql/mysql-connector-java/${MYSQL_DRIVER_VERSION}/mysql-connector-java-${MYSQL_DRIVER_VERSION}.jar \
    && curl -O https://jdbc.postgresql.org/download/postgresql-${POSTGRES_DRIVER_VERSION}.jar \
    && curl -L -O https://oss.sonatype.org/content/repositories/releases/org/mongodb/mongo-java-driver/${MONGODB_DRIVER_VERSION}/mongo-java-driver-${MONGODB_DRIVER_VERSION}.jar \
    && curl -O https://downloads.mariadb.com/Connectors/java/connector-java-${MARIADB_DRIVER_VERSION}/mariadb-java-client-${MARIADB_DRIVER_VERSION}.jar \
    && apk del --purge curl

# Retreive and install artifact from builder
COPY --from=builder pwm/webapp/target/pwm-${APP_VERSION}.war /tmp/pwm-${APP_VERSION}.war

RUN cd /tmp \
    && unzip /tmp/pwm-${APP_VERSION}.war -d ${PWM_HOME} \
    && rm -f /tmp/pwm-${APP_VERSION}.war \
    && chmod a+x ${PWM_HOME}/WEB-INF/command.sh \
    && cd $CATALINA_HOME \
    && xmlstarlet ed \
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
COPY docker-entrypoint.sh /

# Fix permissions
RUN chmod +x /docker-entrypoint.sh \
    && chown -R pwm:pwm $CATALINA_HOME \
    && chown -R pwm:pwm $PWM_PATH

USER pwm

WORKDIR $CATALINA_HOME

EXPOSE 8080

#ENTRYPOINT ["/sbin/docker-entrypoint.sh"]

CMD ["catalina.sh", "run"]
