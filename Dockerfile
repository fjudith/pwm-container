FROM tomcat:jre8

MAINTAINER Florian JUDITH <florian.judith.b@gmail.com>

ENV VERSION=pwm-1.8.0-SNAPSHOT-2017-07-10T03:44:47Z-pwm-bundle

ENV PWM_HOME=${CATALINA_HOME}/webapps/pwm

RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wget unzip xmlstarlet

# Create pwm user
RUN groupadd --system --gid 1234 pwm && \
	useradd --system --create-home --shell /bin/bash --gid 1234 --uid 1234 pwm

# Download & deploy pwm.war
RUN cd /tmp && \
    wget https://www.pwm-project.org/artifacts/pwm/${VERSION}.zip && \
    unzip ${VERSION}.zip -d /tmp/pwm && \
    unzip /tmp/pwm/pwm.war -d  ${PWM_HOME} && \
    chmod a+x ${PWM_HOME}/WEB-INF/command.sh

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
RUN chown -R pwm:pwm $CATALINA_HOME


USER pwm

WORKDIR $CATALINA_HOME

EXPOSE 8080

ENTRYPOINT ["/sbin/docker-entrypoint.sh"]

CMD ["catalina.sh", "run"]