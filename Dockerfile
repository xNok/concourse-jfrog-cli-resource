FROM openjdk:8-jre-alpine

RUN apk add --no-cache curl jq bash git openssh-client

ADD assets/ /opt/resource/
ADD build/libs/maven-versions-sorter.jar /opt/resource/libs/

RUN echo -e '#!/bin/bash\n\njava -jar /opt/resource/libs/maven-versions-sorter.jar "$@"' > /usr/bin/sort-versions && chmod uog+x /usr/bin/sort-versions
