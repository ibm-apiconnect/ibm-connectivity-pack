# IBM Connectivity Pack

IBM Connectivity pack consists of connector framework and a huge set of connectors that are designed to help IBM Software products to solve their connectivity requirements. It is a reusable asset that can deployed within a product scope. It offers consistent interface through ReST APIs, using Open standards.

## Contents

- [Prerequisites](./README.md#prerequisites)
- [Installing the IBM Connectivity Pack](./README.md#installing-the-ibm-connectivity-pack)

## Prerequisites

- Kubernetes 1.16+
- Helm 3.0+
- OpenShift 4.x (for Route and OpenShift-specific features)
- Credentials used for APIC image pull secret.

## Installing the IBM Connectivity Pack

The Connectivity Pack acts as an interface between connector endpoints and Codegen service. It can be deployed on OpenShift and other Kubernetes platforms by using the Connectivity Pack Helm chart.

### Clone the repository
Clone the repository in your enviroment.

### Generate certificates
The connector service provides an option to enable MTLS communication.

#### Option to enable MTLS
Run the below command to set the environment variable
```
export MTLS_ENABLED=true
```

#### Create secrets
Run the below command to set the environment variables
```
export RELEASE_NAME=<RELEASE_NAME>
export RELEASE_NAMESPACE=<RELEASE_NAMESPACE>
export DNS2=$RELEASE_NAME-service.$RELEASE_NAME.svc.cluster.local
export DNS3=<route.domain>
export PKCS_PASSWORD=<certificate.pkcsPassword>
```

Where:

- `<RELEASE_NAME>` is the release name of your choice. For example, `ibm-connectivity-pack`
- `<RELEASE_NAMESPACE>` is the namespace where you want to install the Connectivity Pack.
- `<route.domain>` is the subdomain of OpenShift cluster where connector service is being deployed. It's value should be same as mentioned in `values.yaml` file.
- `<certificate.pkcsPassword>` Only needed when MTLS is enabled. This password protects certificate and private key. It's value should be same as mentioned in `values.yaml` file.


Now login to your Openshift instance using `oc` commmand line tool.

Navigate to the `scripts` directory and run the following commands:
```
chmod +x createCert.sh
./createCert.sh
```
The above command will create new secret/s in your Openshift namespace.

### Install Connectivity Pack

Navigate to `helm` directory.

#### Update values.yaml file

If image pull secret name if already exists, please specify here
1. `image.imagePullSecretName`

Else give below values for creating new Image pull secret
1. `image.imagePullEmail`
2. `image.imagePullUsername`
3. `image.imagePullPassword`

If MTLS is enabled, update the following in the `values.yaml` file:
1. `certificate.MTLSenable`: true
2. `certificate.pkcsPassword`: A strong password to protect certificate and private key.

#### Use helm to install connectivity pack

Navigate to the `helm` directory.
Run the following command to package your helm chart.
```
helm package ./
```

To install the Connectivity Pack, run the following command:

```bash
helm install $RELEASE_NAME ./ibm-connectivity-pack-1.4.2.tgz -n $RELEASE_NAMESPACE --set license.accept=true --set certificate.serverSecretName=$RELEASE_NAME-server-secrets --set certificate.clientSecretName=$RELEASE_NAME-client-secrets
```

Where:
license.accept determines whether the license is accepted (default is false if not specified).
certificate.serverSecretName points connectivity pack to server secrets
certificate.clientSecretName points connectivity pack to client secrets

You can override the default configuration parameters by using the `--set` flag or by using a custom YAML file. For example, to set the `replicaCount` as `3`, you can use `--set replicaCount=3`.

For more information about installing the Connectivity Pack, including a complete list of configuration parameters supported by the Helm chart, see [installing the Connectivity Pack](/helm/README.md#configuration).

## Accessing Connectivity Pack via Route

To access connectivity pack, use the host url present in the Routes section of Openshift.

If MTLS is enabled, the client certificates can be fetched from the Secrets section of Openshift. Secret with name `RELEASE_NAME-client-secrets` contains the secrets.
