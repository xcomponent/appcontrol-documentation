# AppControl Installation Guide for OpenShift

## 1. Introduction

This guide describes the installation process for AppControl on an OpenShift cluster. It covers Helm charts, configuration steps, and verification procedures.

## 2. Requirements

### 2.1 OpenShift Cluster

Ensure that you have an OpenShift cluster with a dedicated project (namespace) for deploying AppControl. If OpenShift is not running, start it with:

```sh
crc start
```

To create the namespace if it does not exist:

```sh
oc new-project Appcontrol || oc project Appcontrol
```

### 2.2 OpenShift Ingress (Default Router)

OpenShift includes an Ingress controller by default via its built-in **Router** (HAProxy). Instead of configuring an additional Ingress controller, we will use OpenShift's native Route system to expose the application.

### 2.3 SQL Server Database

AppControl requires a Microsoft SQL Server database.

-   **Required version**: SQL Server 2017+
-   **Example connection string**:
    ```
    Server=tcp:MY_SERVER_IP,1433;Initial Catalog=MYDATABASE;Persist Security Info=False;User ID=USERID;Password=PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;Connection Timeout=30;
    ```
    This connection string will be required in the `appcontrol_values.yaml` file, which is used when deploying AppControl with Helm.

### 2.4 Redis

AppControl uses Redis for caching and persistent storage.

-   **Example connection string**:
    ```
    redis://USER:PASSWORD@HOST:PORT
    ```
    Replace `YOUR_REDIS_CONNECTION_STRING` accordingly.

### 2.5 RabbitMQ

A RabbitMQ instance should be set up with a dedicated virtual host.

-   **Example connection details**:
    ```
    Host: YOUR_RABBIT_HOST
    Virtual Host: APPCONTROL_VIRTUAL_HOST
    User: YOUR_USERNAME
    Password: YOUR_PASSWORD
    ```

### 2.6 Configuring the AppControl Domain

Define a DNS entry for the AppControl platform.

If you are deploying elsewhere, ensure that this domain is properly configured.

-   **Example domains**:
    -   AppControl: `appcontrol.MyCompany.com`

This domain will be used later in the configuration.

## 3. Platform Configuration

### 3.1 Helm Repository Setup

Before installing Helm charts, authenticate to the Helm registry using credentials provided by the AppControl editor:

```sh
helm registry login x4bcontainerregistry.azurecr.io --username login --password password
```

Set up the Helm repository:

```sh
REPO="oci://x4bcontainerregistry.azurecr.io/helm"
```

### 3.2 Application Configuration

The configuration templates for AppControl are available in the repository:

-   [applications-template.json](https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/applications-template.json)
-   [services-template.json](https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/services-template.json)

To use them in your deployment, replace `MY_APPCONTROL_DOMAIN` dynamically:

```sh

MY_APPCONTROL_DOMAIN="appcontrol.MyCompany.com"

oc create configmap appcontrol-config \
  --from-literal=applications.json="$(curl -s https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/applications-template.json | sed "s/MY_APPCONTROL_DOMAIN/$MY_APPCONTROL_DOMAIN/g")" \
  --from-literal=services.json="$(curl -s https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/services-template.json | sed "s/MY_APPCONTROL_DOMAIN/$MY_APPCONTROL_DOMAIN/g")"
```

### 3.3 JWT Secret Keys

The secret name used for JWT keys in OpenShift is **jwt-keys**. This name must be referenced later in the configuration.

Generate a self-signed certificate and create a secret for JWT keys:

```sh
openssl genpkey -algorithm RSA -out jwt-private.pem
openssl rsa -pubout -in jwt-private.pem -out jwt-public.pem
```

Then, create the secret in OpenShift:

```sh
oc create secret generic jwt-keys -n Appcontrol \
  --from-file=jwt-private.pem=jwt-private.pem \
  --from-file=jwt-public.pem=jwt-public.pem
```

## 4. Helm Chart Installation

### 4.1 Install AppControl Services

The configuration template for `x4b-services-values.yaml` is available in the repository:

-   [x4b-services-values.yaml](https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/x4b-services-values.yaml)

To view all possible values before installing:

```sh
helm show values "$REPO/appcontrol-services"
```

To install the services with customized values:

```sh
MY_APPCONTROL_DOMAIN="appcontrol.MyCompany.com"
MY_SECRET_NAME="jwt-keys"
YOUR_SQLSERVER_CONNECTION_STRING="your_sqlserver_connection_string"

helm install appcontrol-services "$REPO/appcontrol-services" \
  --namespace Appcontrol \
  -f https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/x4b-services-values.yaml \
  --set externalHostname="x4b.$MY_APPCONTROL_DOMAIN" \
  --set jwtSecretName="$MY_SECRET_NAME" \
  --set sql.connectionString="$YOUR_SQLSERVER_CONNECTION_STRING"
  --namespace Appcontrol
```

### 4.2 Install AppControl

```sh
helm install appcontrol "$REPO/appcontrol" \
  --namespace Appcontrol \
  -f appcontrol_values.yaml
```

To view all possible values before installing:

```sh
helm show values "$REPO/appcontrol-services"
```

To install the services with customized values:

```sh
MY_APPCONTROL_DOMAIN="appcontrol.MyCompany.com"
HTTTPROTOCOL=https
YOUR_SQLSERVER_CONNECTION_STRING="your_sqlserver_connection_string"
RABBITMQ_HOST_NAME="Your rabbitmq host eg: rabbitmq.rabbitmq.svc.cluster.local"
RABBITMQ_USER="Your rabbitmq user"
RABBITMQ_PASSWORD="Your rabbitmq password"
RABBITMQ_VHOST="Your rabbitmq vhost"
# Download and replace all instances of MY_APPCONTROL_DOMAIN
curl -s https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/appcontrol_values.yaml \
  | sed "s/MY_APPCONTROL_DOMAIN/${MY_APPCONTROL_DOMAIN}/g" \
  | sed "s/HTTTPROTOCOL/${HTTTPROTOCOL}/g" \
  > /tmp/appcontrol_values.yaml

# Install using the updated YAML file
helm install appcontrol-services "$REPO/appcontrol-services" \
  --namespace Appcontrol \
  -f /tmp/appcontrol_values.yaml
  --set jwtSecretName="$MY_SECRET_NAME" \
  --set dbaccess.connectionString="$YOUR_SQLSERVER_CONNECTION_STRING"
  --set rabbitmq.hostname="$RABBITMQ_HOST_NAME"
  --set rabbitmq.username="$RABBITMQ_USER"
  --set rabbitmq.password="$RABBITMQ_PASSWORD"
  --set rabbitmq.virtualHost="$RABBITMQ_VHOST"
  --namespace Appcontrol
```

## 5. Exposing AppControl in OpenShift

### 5.1 Create an OpenShift Route

Instead of using an Ingress resource, OpenShift provides a built-in Router to expose services externally. To expose AppControl, create a Route:

```sh
oc expose svc/appcontrol --hostname=MY_APPCONTROL_DOMAIN
```

This will generate a public endpoint for AppControl.

### 5.2 Verify the Created Route

Check if the Route has been created successfully:

```sh
oc get routes
```

Example output:

```
NAME          HOST/PORT                 PATH   SERVICES      PORT   TERMINATION   WILDCARD
appcontrol    myapp.openshift.local            appcontrol    8080   edge
```

### 5.3 Enable TLS (If Required)

To enable **TLS termination**, create a secure Route:

```sh
oc create route edge appcontrol --service=appcontrol --hostname=MY_APPCONTROL_DOMAIN
```

This ensures HTTPS is enforced at the OpenShift Router level.

## 6. Checking Deployment Status

### 6.1 Verify Helm Charts

```sh
helm ls -n Appcontrol
helm status appcontrol
```

### 6.2 Verify Running Pods

```sh
oc get pods -l 'app.kubernetes.io/instance in (appcontrol-services,appcontrol)' -n Appcontrol
```

### 6.3 Verify AppControl Accessibility

Open your browser and navigate to:

```
https://MY_APPCONTROL_DOMAIN
```
