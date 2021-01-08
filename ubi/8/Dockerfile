FROM registry.access.redhat.com/ubi8/ubi:latest AS TZDATA

FROM registry.access.redhat.com/ubi8/ubi-minimal:latest

LABEL maintainer="adorsys GmbH & Co. KG" \
      vendor="adorsys GmbH & Co. KG" \
      name="adorsys/java:8" \
      org.label-schema.vendor="adorsys GmbH & Co. KG" \
      org.label-schema.name="adorsys/java:8" \
      io.k8s.display-name="adorsys/java:8" \
      summary="adorsys/java:8" \
      io.k8s.description="adorsys/java:8" \
      org.label-schema.description="adorsys/java:8" \
      org.label-schema.schema-version="1.0" \
      org.label-schema.usage="" \
      org.label-schema.license="" \
      org.label-schema.build-date=""

EXPOSE 8080

# https://stackoverflow.com/questions/39163590/how-to-set-utf-8-character-encoding-in-spring-boot
ENV TZ=Europe/Berlin \
    LC_ALL=C.UTF-8 \
    JAVA_OPTS="-Xmx128m" \
    JAVA_HOME="/usr/lib/jvm/jre"

WORKDIR /opt/app-root/src

# https://bugzilla.redhat.com/show_bug.cgi?id=1611117
COPY --from=TZDATA /usr/share/zoneinfo/UTC /usr/share/zoneinfo/UTC
COPY --from=TZDATA /usr/share/zoneinfo/Europe/Berlin /usr/share/zoneinfo/Europe/Berlin

RUN microdnf --noplugins update -y && microdnf --noplugins clean all && rm -rf /var/cache/yum \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && microdnf --noplugins install --nodocs -y openssl java-1.8.0-openjdk-headless && microdnf --noplugins clean all \
    && chmod g=u /etc/passwd

COPY root /

ENTRYPOINT ["/docker-entrypoint.sh"]

CMD exec java $JAVA_OPTS -jar *.jar

USER 1001
