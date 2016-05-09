#!/bin/bash
# Creates a copy of the trusted cacerts, adds let's encrypt certificats, and advices maven to use the new trust store.

cp $JAVA_HOME/jre/lib/security/cacerts /tmp
wget -P /tmp https://letsencrypt.org/certs/isrgrootx1.pem
keytool -trustcacerts -keystore /tmp/cacerts -storepass changeit -noprompt -importcert -file /tmp/isrgrootx1.pem -alias isrgrootx1
wget -P /tmp https://letsencrypt.org/certs/letsencryptauthorityx1.der
keytool -trustcacerts -keystore /tmp/cacerts -storepass changeit -noprompt -importcert -file /tmp/letsencryptauthorityx1.der -alias letsencryptauthorityx1
export MAVEN_OPTS="-Djavax.net.ssl.trustStore=/tmp/cacerts"