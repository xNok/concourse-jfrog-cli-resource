FROM openjdk:8-jre-alpine

ADD assets/ /opt/resource/
ADD build/libs/maven-versions-sorter.jar /opt/resource/libs/
ADD https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 /usr/bin/jq

RUN apk add --update curl && rm -rf /var/cache/apk/*
RUN echo '#!/bin/bash\n\njava -jar /opt/resource/libs/maven-versions-sorter.jar "$@"' > /usr/bin/sort-versions && chmod uog+x /usr/bin/sort-versions && chmod uog+x /usr/bin/jq