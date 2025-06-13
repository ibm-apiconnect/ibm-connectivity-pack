#!/bin/bash

OPENSSL_SERVER_CONF=$(mktemp /tmp/opensslServerXXXXXXX.cnf)
OPENSSL_CLIENT_CONF=$(mktemp /tmp/opensslClientXXXXXXX.cnf)
CA_KEY=$(mktemp /tmp/ca-keyXXXXXXX.pem)
CA_CERT=$(mktemp /tmp/ca-certXXXXXXX.pem)
CA_SRL=$(mktemp /tmp/ca-certXXXXXXX.srl)
SERVER_KEY=$(mktemp /tmp/SERVER-keyXXXXXXX.pem)
SERVER_CERT=$(mktemp /tmp/SERVER-certXXXXXXX.pem)
CLIENT_KEY=$(mktemp /tmp/CLIENT-keyXXXXXXX.pem)
CLIENT_CERT=$(mktemp /tmp/CLIENT-certXXXXXXX.pem)
CLIENT_CERT_P12=$(mktemp /tmp/CLIENT-certXXXXXXX.p12)
SERVER_CERT_CSR=$(mktemp /tmp/SERVERXXXXXXX.csr)
CLIENT_CERT_CSR=$(mktemp /tmp/CLIENTXXXXXXX.csr)
echo 1000 > $CA_SRL

SERVER_SECRET_NAME="${RELEASE_NAME}-server-secrets"
CLIENT_SECRET_NAME="${RELEASE_NAME}-client-secrets"
CA_CERT_NAME="ca.crt"
SERVER_CERT_NAME="tls.crt"
SERVER_KEY_NAME="tls.key"
CLIENT_CERT_NAME="tls.crt"
CLIENT_KEY_NAME="tls.key"
CLIENT_PKCS_P12="pkcs.p12"

export COMMON_NAME="${RELEASE_NAME}-service"
export DNS2="${RELEASE_NAME}-service.${RELEASE_NAME}.svc.cluster.local"
export ROUTE_ENABLED=true


export EXTEND_KEY_USAGE="extendedKeyUsage = serverAuth"
sh certConf.sh  > $OPENSSL_SERVER_CONF

export EXTEND_KEY_USAGE="extendedKeyUsage = clientAuth"
sh certConf.sh  > $OPENSSL_CLIENT_CONF

# Generate the mTLS certificate using openssl
echo "Generating Certificates..."
openssl genrsa -out $CA_KEY
openssl req -x509 -new -nodes -key $CA_KEY -days 999 -out $CA_CERT -subj "/CN=${RELEASE_NAME}-ca"

openssl genrsa -out $SERVER_KEY
openssl req -new -key $SERVER_KEY -out $SERVER_CERT_CSR -config $OPENSSL_SERVER_CONF
openssl x509 -req -in $SERVER_CERT_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -CAserial $CA_SRL -out $SERVER_CERT -days 999 -extensions v3_req -extfile $OPENSSL_SERVER_CONF
oc create secret generic $SERVER_SECRET_NAME --from-file=$CA_CERT_NAME=$CA_CERT --from-file=$SERVER_CERT_NAME=$SERVER_CERT --from-file=$SERVER_KEY_NAME=$SERVER_KEY -n $RELEASE_NAMESPACE -o yaml --dry-run=client | oc apply -f - 

if [ "$MTLS_ENABLED" == true ]; then 
openssl genrsa -out $CLIENT_KEY
openssl req -new -key $CLIENT_KEY -out $CLIENT_CERT_CSR -config $OPENSSL_CLIENT_CONF
openssl x509 -req -in $CLIENT_CERT_CSR -CA $CA_CERT -CAkey $CA_KEY -CAcreateserial -CAserial $CA_SRL -out $CLIENT_CERT -days 999 -extensions v3_req -extfile $OPENSSL_CLIENT_CONF
openssl pkcs12 -export -in $CLIENT_CERT -inkey $CLIENT_KEY -out $CLIENT_CERT_P12 -name "client-cert" -CAfile $CA_CERT -caname "CA" -passout pass:$PKCS_PASSWORD
oc create secret generic $CLIENT_SECRET_NAME --from-file=$CA_CERT_NAME=$CA_CERT --from-file=$CLIENT_CERT_NAME=$CLIENT_CERT --from-file=$CLIENT_KEY_NAME=$CLIENT_KEY --from-file=$CLIENT_PKCS_P12=$CLIENT_CERT_P12 -n $RELEASE_NAMESPACE -o yaml --dry-run=client | oc apply -f -
fi

cleanup() {
  rm -f $OPENSSL_SERVER_CONF $OPENSSL_CLIENT_CONF $CA_KEY $CA_CERT $CA_SRL \
        $SERVER_KEY $SERVER_CERT $CLIENT_KEY $CLIENT_CERT $CLIENT_CERT_P12 \
        $SERVER_CERT_CSR $CLIENT_CERT_CSR
}
trap cleanup EXIT
