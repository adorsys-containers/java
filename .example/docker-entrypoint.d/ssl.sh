#!/bin/sh

# https://developers.redhat.com/blog/2017/11/22/dynamically-creating-java-keystores-openshift/

SERVER_SSL_PEM_KEY="${SERVER_SSL_PEM_KEY:-/var/run/secrets/serving-cert-secret/tls.key}"
SERVER_SSL_PEM_CRT="${SERVER_SSL_PEM_KEY:-/var/run/secrets/serving-cert-secret/tls.crt}"

# Import private key from openshift services serving certs
if [ -f "${SERVER_SSL_PEM_KEY}" ] && [ -f "${SERVER_SSL_PEM_CRT}" ]; then
  # spring boot auto config
  # https://docs.spring.io/spring-boot/docs/current/reference/htmlsingle/#howto-configure-ssl

  SERVER_PORT="${SERVER_PORT:-8443}"
  SERVER_SSL_ENABLED_PROTOCOLS="${SERVER_SSL_ENABLED_PROTOCOLS:-TLSv1.2}"
  SERVER_SSL_KEY_STORE="${SERVER_SSL_KEY_STORE:-/tmp/keystore.p12}"
  SERVER_SSL_KEY_STORE_PASSWORD="${SERVER_SSL_KEY_STORE_PASSWORD:-changeit}"
  SERVER_SSL_KEY_STORE_TYPE=PKCS12
  SERVER_SSL_KEY_ALIAS="${SERVER_SSL_KEY_STORE_PASSWORD:-tomcat}"
  SECURITY_REQUIRE_SSL="${SECURITY_REQUIRE_SSL:-true}"

  if [ -n "${SERVER_SSL_KEY_STORE+x}" ]; then
    if [ ! -f "${SERVER_SSL_KEY_STORE}" ]; then
      (
        cd /tmp
        export RANDFILE=/tmp/.rnd
        openssl pkcs12 -export \
          -inkey "${SERVER_SSL_PEM_KEY}" \
          -in "${SERVER_SSL_PEM_CRT}" \
          -out "${SERVER_SSL_KEY_STORE}" \
          -name "${SERVER_SSL_KEY_ALIAS}" \
          -password pass:"${SERVER_SSL_KEY_STORE_PASSWORD}"
      )
    fi
  fi
fi

SSL_TRUSTSTORE="${SSL_TRUSTSTORE:-/tmp/truststore.p12}"

CA_BUNDLE_OPENSHIFT="${CA_BUNDLE_OPENSHIFT:-/var/run/secrets/kubernetes.io/serviceaccount/service-ca.crt}"
CA_BUNDLE_CUSTOM="${CA_BUNDLE_CUSTOM:-/var/run/secrets/openshift.io/ca-bundle/ca.pem}"

# Import openshift and custom ca bundle into a java keystore
if [ ! -f "${SSL_TRUSTSTORE}" ]; then
  cp /etc/pki/java/cacerts "${SSL_TRUSTSTORE}"
  chmod 640 "${SSL_TRUSTSTORE}"

  if [ -f "${CA_BUNDLE_OPENSHIFT}" ]; then
    (
      cd /tmp
      csplit -s -z -f crt- "${CA_BUNDLE_OPENSHIFT}" '/-----BEGIN CERTIFICATE-----/' '{*}'
      for file in crt-*; do
        keytool -import -noprompt -keystore "${SSL_TRUSTSTORE}" -file "${file}" -storepass changeit -alias service-"${file}"
        rm "${file}"
      done
    )
  fi

  if [ -f "${CA_BUNDLE_CUSTOM}" ]; then
    (
      cd /tmp
      csplit -s -z -f crt- "${CA_BUNDLE_CUSTOM}" '/-----BEGIN CERTIFICATE-----/' '{*}'
      for file in crt-*; do
        keytool -import -noprompt -keystore "${SSL_TRUSTSTORE}" -file "${file}" -storepass changeit -alias service-"${file}"
        rm "${file}"
      done
    )
  fi
fi

if [ -f "${CA_BUNDLE_OPENSHIFT}" ] || [ -f "${CA_BUNDLE_CUSTOM}" ]; then
  JAVA_OPTS="${JAVA_OPTS:-} -Djavax.net.ssl.trustStore=\"${SSL_TRUSTSTORE}\" -Djavax.net.ssl.trustStorePassword=\"changeit\""
fi
