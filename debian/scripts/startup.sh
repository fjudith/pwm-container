#!/usr/bin/env bash
#PWM Docker Container startup script

PWM_HOME=${CATALINA_HOME}/webapps/pwm
CATALINA_HOME=/usr/local/tomcat

#Explode war
rm -rf $PWM_HOME
mkdir $PWM_HOME
unzip /appliance/pwm.war -d $PWM_HOME

#fix script executable flag
cd $PWM_HOME/WEB-INF
chmod a+x command.sh

# update the https certificate file used by tomcat
rm /appliance/https-cert
./command.sh ExportHttpsKeyStore /appliance/https-cert https password

# update the https configuration used by tomcat
rm $CATALINA_HOME/conf/server.xml
./command.sh ExportHttpsTomcatConfig /appliance/server.xml.source $CATALINA_HOME/conf/server.xml

# start tomcat
rm -rf $CATALINA_HOME/work/*
useradd pwm
chown -R pwm. $CATALINA_HOME
chown -R pwm. /config
cd $CATALINA_HOME/bin
su pwm -c './catalina.sh run'
