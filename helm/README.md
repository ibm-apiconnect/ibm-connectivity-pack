# IBM Connectivity pack Helm Chart
This Helm chart deploys the IBM Connectivity pack application, which consists of multiple components such as proxy, action, connector-java-services and event services, with options to configure MTLS, basic authentication, auto-scaling, and more. This application is designed to run in Kubernetes and OpenShift environments.

## Prerequisites
- Kubernetes 1.16+
- Helm 3.0+
- Optional: OpenShift 4.x (for Route and OpenShift-specific features)

## Installation
Add Helm Repository
```bash
export VERSION='1.0.0'
helm pull oci://us.icr.io/csa-helm-charts/ibm-connectivity-pack --version $VERSION
`tar -xzf ibm-connectivity-pack-${VERSION}.tgz `
`rm ibm-connectivity-pack-${VERSION}.tgz`
```

## Install the Chart
To install the chart with the release name `my-release`:
```bash
helm install my-release connector-service/ibm-connectivity-pack
```

You can also customize the chart by passing values through the `--set` flag or by using a custom values.yaml file.
```bash
helm install my-release connector-service/ibm-connectivity-pack -f values.yaml --set replicaCount=3
```

## Upgrade the Chart

To upgrade an existing release with new values:
```bash
helm upgrade my-release connector-service/ibm-connectivity-pack -f values.yaml
```

## Uninstallation

To uninstall/delete the `my-release` deployment:
```bash
helm uninstall my-release
```

## Configuration

The following table lists the configurable parameters of the **IBM Connectivity pack** chart and their default values:

Parameter | Description | Default
-- | -- | --
skipHooks | This is to skip install or upgrade hooks and uninstall hooks. Don't skip if certificate.enable is true | false
namespace | This namespace will used instead of release one if value is given other than empty | ''
license.accept | Set license.accept to true. Accept the license before insatlling or updating HELM else prehook will throw error | false
replicaCount | Number of replicas of the pod | 1
bunyan | Log configuration for the application | Possible values [Logging](#logging)
annotations | Override with product specific annotations | Refer k8's annotation for more info
environmentVariables | Yaml object of environment variables to be added in action and event services | {}
architecture| Select the k8's Node Architecture, possible values are amd64 s390x ppc64le | amd64
image.registry | Image registry URL | us.icr.io
image.path | Image namespace/path under image registry before image name and digest | conn-pack-prod-ns
image.imagePullSecretName| K8's image pull secrete if it already exist in namespace if not add below image pull details to create new secret | ''
image.imagePullEmail | Image pull secret email ID | dummyEmail
image.imagePullUsername | Image pull username | iamapikey
image.imagePullPassword | Image pull password | dummyPassword
certificate.enable | Enable TLS/MTLS and add new certificate or consume the existing certificate | true
certificate.MTLSenable | Enable MTLS else fallback to TLS, By default TLS will be enabled | false
certificate.generate | Generate new certificates for MTLS/TLS, this should be used for Certificate rotation and this is not honoured if certificate.serverSecretName and / or certificate.clientSecretName is given | false
certificate.clientSecretName | Already existing MTLS client certificate k8 secret name, If kept empty new certificate will be generated on helm install | '' 
certificate.clientCertPropertyName | Property name in secrete which holds MTLS client certificate | 'tls.crt' 
certificate.clientCertKeyPropertyName | Property name in secrete which holds MTLS client certificate key | 'tls.key'
certificate.clientCertPKCSPropertyName | Property name in secrete which holds PKCS12 client certificate | 'pkcs.p12'
certificate.pkcsPassword | PKCS12 file password | ''
certificate.serverSecretName | Already existing MTLS/TLS server certificate k8 secret name, If kept empty new certificate will be generated on helm install | '' 
certificate.serverCertPropertyName | Property name in secrete which holds MTLS/TLS server certificate | 'tls.crt'
certificate.serverCertKeyPropertyName | Property name in secrete which holds MTLS/TLS server certificate key |'tls.key'
certificate.caCertPropertyName | Property name in secrete which holds certificate authority certificate | 'ca.crt'
route.enable | Enable OpenShift Route for external access update domain and make `certificate.generate` to true so that certificate has the domain entry, *Enable only for OpenShift cluster*  | false
route.domain | Domain or subdoamin of cluster | 'example.com' 
basicAuth.enable | Enable basic authentication for service | false
basicAuth.username | Basic auth username | csuser
preHook.image | Prehook job image name | connectivity-pack-prehook
preHook.digest.amd64 | Prehook job image digest for amd64 architecture | ''
preHook.digest.s390x | Prehook job image digest for s390x architecture | ''
preHook.digest.ppc64le | Prehook job image digest for ppc64le architecture | ''
proxy.image | Proxy service container image name | connectivity-pack-proxy
proxy.digest.amd64 | Proxy service container image digest for amd64 architecture | ''
proxy.digest.s390x | Proxy service container image digest for s390x architecture | ''
proxy.digest.ppc64le | Proxy service container image digest for ppc64le architecture | ''
enableRefreshTokenMode | If set to true, a service will be exposed that the consumer must call to refresh an expired access token; otherwise, the framework will handle the automatic access token refresh for OAuth2-supported applications. | false
action.image | Action service container image name | action-connectors
action.digest.amd64 | Action service container image digest for amd64 architecture| ''
action.digest.s390x | Action service container image digest for s390x architecture| ''
action.digest.ppc64le | Action service container image digest for ppc64le architecture| ''
action.resources | Action service container resources Check k8's deployment resources for more details | Please refer values.yaml file
event.enable | Enable event container | false
event.image | Event service container image name | event-connectors
event.digest.amd64 | Event service container image digest for amd64 architecture| ''
event.digest.s390x | Event service container image digest for s390x architecture| ''
event.digest.ppc64le | Event service container image digest for ppc64le architecture| ''
event.resources | Event service container resources Check k8's deployment resources for more details | Please refer values.yaml file
javaservice.enable | Enable java-service container | false
javaservice.image | java-service container image name | connector-service-java
javaservice.digest.amd64 | java-service container image digest for amd64 architecture |''
javaservice.digest.s390x | java-service container image digest for s390x architecture |''
javaservice.digest.ppc64le | java-service container image digest for ppc64le architecture |''
javaservice.resources | java-service container resources Check k8's deployment resources for more details | Please refer values.yaml file
autoScaling.enable | Enable auto-scaling | false
autoScaling.minReplicas | Minimum replicas for auto-scaling | 1
autoScaling.maxReplicas | Maximum replicas for auto-scaling | 5
autoScaling.cpuUtilization | Target CPU utilization percentage for auto-scaling | 70
autoScaling.memoryUtilization | Target memory utilization percentage for auto-scaling | 70

## MTLS Configuration
The chart supports both MTLS and TLS:

**MTLS Enabled:** Certificates are generated and stored in a Kubernetes secret. To regenerate certificates, set `certificate.generate` to `true`.
**TLS Fallback:** If MTLS is disabled, the service defaults to TLS. By default TLS is enabled

## To view or manage the MTLS secrets:
```bash
kubectl get secret my-release-mtls-secret -o yaml -n <namespace>
```

## OpenShift Route
To enable an OpenShift Route for external access, set `route.enable` to `true` in the values.yaml file. This will expose your application outside of the cluster via an OpenShift route.

## Basic Authentication
Basic authentication can be enabled for services by setting `basicAuth.enable` to `true`

## Auto-Scaling
The chart supports horizontal pod auto-scaling based on CPU and memory utilization. Configure the settings in `values.yaml`:

```yaml
autoScaling:
  enable: true
  minReplicas: 1
  maxReplicas: 5
  cpuUtilization: 70
  memoryUtilization: 70

```
## Logging
You can configure detailed logging using the `bunyan` configuration in the `values.yaml` file. This supports various logging levels (`info`, `debug`, `trace`, etc.) and output formats.

```js

  {
      "loglevel": 'trace'|'debug'|'info'|'warn'|'error'|'fatal', //  default logging level of all streams (string)
      "logsrc": true|false, // include the source filename and line-number (boolean)
      "logstdout": {
        "loglevel": 'trace'|'debug'|'info'|'warn'|'error'|'fatal'
      },
      "logstdouttext": {
        "ignoredlogsources": ["shoutyFile.js", "somedir/loudClass.js"] // ignore logs from files with a path matching any of these regexes (array of RegExp strings).  This will set 'logsrc' to true"
      },
      "logstdoutlogdna": {},
      "logfile": {
        "loglevel": 'trace'|'debug'|'info'|'warn'|'error'|'fatal',
        "filename": "mydir/myfile.log", // The path and name of a file to write logs to (string)
        "rotate": true|false, // if true turns on bunyan 'rotating-file' log file rotation, (boolean - defaults to false)
        "rotatecount": 3, // number of files for rotation if active, (number - defaults to 10)
        "rotateperiod": "12h", // log rotation period for rotation if active, time duration eg '1d' or '6h', (string defaults to '1d'
      },
      "logstdoutdashboard" : {
        "logformat": "basic"|"json" // optional, default=basic
      },
      logstdoutwo: {},
      "logdna": {
        "url": 'https://logs.eu-de.logging.cloud.ibm.com/logs/ingest', // ingestion URL for the logDNA instance (string - found on the logDNA dashboard, under '?' (bottom left) > 'REST API' > The value MUST end with /ingest, trim off all the query parameters
        "key": "abc123def456ghi789abc123def456gh", // ingestion key for the logDNA instance (string - found on the logDNA dashboard, under 'settings' > 'ORGANIZATION' > ' API Keys'
        "flushlimit": 1000000, // maximum log buffer size (in bytes) allowed before which the buffer is automatically flushed (default=5000000)
        "flushinterval": 100 //  duration (in ms) to wait from the last flush before the next automated log buffer flush, when flushlimit isn't exceeded (default=250)"
      }
    }
```
