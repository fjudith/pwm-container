[![Container Images](https://github.com/fjudith/docker-pwm/actions/workflows/build-push-oci.yml/badge.svg)](https://github.com/fjudith/docker-pwm/actions/workflows/build-push-oci.yml)

# Introduction

PWM is a free and opensource password self service application enabling end-users to reset their enterprise password themselves.


# Description

The Dockerfile builds from `tomcat:9-jre11-slim` see <https://hub.docker.com/r/amd64/tomcat/>

# Version

[`2.0.5`, `latest`](https://github.com/pwm-project/pwm/tree/v2_0_5)

# Quick Start 

Run the PWM image:

```bash
docker run --rm -it --name=pwm -p 8080:8080 fjudith/pwm:alpine
```

NOTE: Please allow few seconds for the application to start, especially if populating the database for the first time.
If you want to make sure that everything wen find, what the logs using the following command:

```bash
docker logs pwm
```

Go to the `http://localhost:8080` or point to the IP or fully qualified name of your docker host. On a Mac or Windows, replace `localhost`with the IP address of your Docker host which you can get using the following command:

```bash
docker-machine ip default
```

# Configuration

# Database

By default, PWM extends the LDAP schema. If you don't want to, the image supports linking to a `mongodb`, `mysql` or `postgres` database container.


## Persistent volume

If you use this image in production, you'll probably want to persist the following locations in a volume.

```text
/usr/share/pwm                  # PWM configuration
```
