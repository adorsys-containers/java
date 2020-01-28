#!/bin/bash

set -euo pipefail

docker run --rm "${DOCKER_IMAGE}:${TAG}" java -version
docker run --rm "${DOCKER_IMAGE}:${TAG}" openssl version
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'date | grep -E "CES?T"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'locale | grep -q LC_ALL=C.UTF-8'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'java -XshowSettings:properties -version |& grep "file.encoding = UTF-8"'
docker run --rm "${DOCKER_IMAGE}:${TAG}" bash -c 'ldd /usr/lib/libtcnative-1.so | grep -vz "=> not found"'

docker run --rm -eSPRING_MAIN_BANNER-MODE=off -v "$(git rev-parse --show-toplevel)/test-applications/java/example-app/target/dockerhub-pipeline-images-test-jar.jar":/opt/app-root/src/app.jar "${DOCKER_IMAGE}:${TAG}"
docker run --rm -eSPRING_MAIN_BANNER-MODE=off -e JAVA_OPTS="-Dspring.mandatory-file-encoding=UTF-8" -v "$(git rev-parse --show-toplevel)/test-applications/java/example-app/target/dockerhub-pipeline-images-test-jar.jar":/opt/app-root/src/app.jar "${DOCKER_IMAGE}:${TAG}"
docker run --rm -eSPRING_MAIN_BANNER-MODE=off -v "$(git rev-parse --show-toplevel)/test-applications/java/example-app/target/dockerhub-pipeline-images-test-jar.jar":/opt/app-root/src/app.jar "${DOCKER_IMAGE}:${TAG}" | grep "Loaded APR based Apache Tomcat Native library"

# Test as Openshift UID
docker run --rm -u 1000090000:0 "${DOCKER_IMAGE}:${TAG}" whoami

# Test /docker-entrypoint.d/*.sh
docker run --rm -v "$(git rev-parse --show-toplevel)/test-applications/docker-entrypoint.d/test-docker-entrypoint.d.sh":/docker-entrypoint.d/test.sh "${DOCKER_IMAGE}:${TAG}" java -version | grep "TEST-ENTRYPOINT-HOOK-WORKS!"
