#!/usr/bin/env bash
cd "$(dirname "$0")"
CWD="$(pwd)"
CERT="$CWD/cert"

if [ ! -f ./config.json ]; then
  echo "Required config.json file not found."
  echo "Copy it from config.json.dist then edit it with your own settings."
  exit 1
fi

# certs
if [ -f "$CERT.key" ] || [ -f "$CERT.pem" ] ; then
    echo "Using existing certs"
else
    echo "Generating self-signed certificate OUTSIDE the container,"
    echo "so that you can use them again with a different container"
	openssl req -x509 -new -nodes -newkey rsa:2048 -keyout cert.key -out cert.crt -subj "/C=ZZ/ST=Bliss/L=Local/O=None/OU=DevOps/CN=example.com"
	cat ./cert.crt ./cert.key > ./cert.pem
fi

docker run -it --rm --name auth0-ldap --network=host \
-v "$CWD"/config.json:/opt/auth0-adldap/config.json \
-v "$CWD"/cert.key:/opt/auth0-adldap/certs/cert.key \
-v "$CWD"/cert.pem:/opt/auth0-adldap/certs/cert.pem \
sylnsr/auth0-adldap

# NOTE: this is only an example for you to base your own solution on