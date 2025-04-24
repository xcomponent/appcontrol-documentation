# AppControl Installation Guide for OpenShift

## 1. Introduction

This guide describes the installation process for AppControl on an OpenShift cluster. It covers Helm charts, configuration steps, and verification procedures.

## 2. Requirements

### 2.1 OpenShift Cluster

Ensure that you have an OpenShift cluster with a dedicated project (namespace) for deploying AppControl.

To create the namespace if it does not exist:

```sh
oc new-project Appcontrol
```

### 2.2 OpenShift Ingress (Default Router)

OpenShift includes an Ingress controller by default via its built-in **Router** (HAProxy). Instead of configuring an additional Ingress controller, we will use OpenShift's native Route system to expose the application.

### 2.3 SQL Server Database

AppControl requires a **Microsoft SQL Server** database to operate.

-   **Required version**: SQL Server **2017 or newer**
-   **Example connection string** (used in `appcontrol_values.yaml` when deploying with Helm):

    ```yaml
    connectionString: >
        Server=tcp:MY_SERVER_IP,1433;Initial Catalog=MYDATABASE;
        Persist Security Info=False;User ID=USERID;Password=PASSWORD;
        MultipleActiveResultSets=False;Encrypt=True;
        TrustServerCertificate=False;Connection Timeout=30;
    ```

    This connection string must be provided in the appcontrol_values.yaml file before deploying AppControl via Helm.

#### Running SQL Server in OpenShift

```
⚠️ Important Note:
Microsoft SQL Server cannot be easily deployed on OpenShift using the official Docker image due to OpenShift-specific constraints (e.g., the requirement for containers to run as non-root users).
```

However, if you still want to deploy SQL Server within your OpenShift cluster, Microsoft provides a dedicated approach that is compatible with OpenShift. You can follow the instructions in the official workshop documentation:

🔗 [Deploy SQL Server on OpenShift – Microsoft Workshop](https://github.com/microsoft/sqlworkshops-sqlonopenshift/blob/master/sqlonopenshift/01_Deploy.md)

### 2.4 Redis

AppControl also requires a **Redis** instance, which it uses for both **caching** and **persistent storage** of runtime data.

-   **Example connection string**:
    ```
    redis://USER:PASSWORD@HOST:PORT
    ```
    Replace `YOUR_REDIS_CONNECTION_STRING` accordingly.

This connection string will be requested **later during the installation process**, so make sure you have it ready.

#### Installing Redis (Quick Start Script)

If you don’t already have a Redis instance available, you can deploy one easily using our helper script.

Run the following one-liner to install Redis in your Openshift cluster:

```bash
REDIS_PASSWORD=yourpassword NAMESPACE=your-namespace \
bash <(curl -s https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/install-redis.sh)
```

Make sure your cluster has internet access so that the script can be fetched and executed properly.

**Notes**:

-   If NAMESPACE is not specified, the current Kubernetes namespace will be used.

-   If REDIS_PASSWORD is not provided, the script will use the default password:
    `appcontrolpwd`

#### Redis Connection from Inside the Cluster

Once Redis is installed, you can connect to it from inside the cluster using:

```bash
redis://default:appcontrolpwd@redis-service:6379
default: the default Redis username
```

`appcontrolpwd`: the default password (or the one you specified)

`redis-service`: the internal Kubernetes service name (DNS-resolvable by other pods)

`6379`: the default Redis port

This internal connection string will be used by AppControl during installation.

### 2.5 RabbitMQ

AppControl requires a **RabbitMQ** instance for message queuing and internal communication.

## Installing RabbitMQ (Quick Start)

To install RabbitMQ in your Kubernetes/OpenShift cluster without editing any files locally, run:

```bash
RABBITMQ_USER=myuser RABBITMQ_PASS=mypassword \
curl -s https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/rabbitmq.yaml | \
envsubst | kubectl apply -f -
```

💡 You can omit the variables to use defaults:

Username: `admin`
Password: `admin123`

This setup includes:

-   A Secret with credentials (customizable via environment variables)

-   A RabbitMQ Deployment

-   An internal Service for AMQP traffic

-   An OpenShift Route for accessing the Web UI (port 15672)

#### RabbitMQ Connection from Inside the Cluster

AppControl will connect using:

```yaml
Host: rabbitmq
Port: 5672
Virtual Host: /
Username: your-username
Password: your-password
```

### 2.6 DNS Configuration for AppControl Deployment

AppControl requires **two distinct DNS entries** to operate:

-   `x4b.mycompany.com` – for the X4B core platform
-   `appcontrol.mycompany.com` – for the AppControl web interface

---

#### ✅ Define the Primary Domain

In your configuration, you only need to define the **main domain** (e.g. `mycompany.com`):

```bash
export MY_APPCONTROL_DOMAIN=mycompany.com
```

The system will automatically derive the necessary subdomains:

-   x4b.${MY_APPCONTROL_DOMAIN} for the X4B backend

-   appcontrol.${MY_APPCONTROL_DOMAIN} for the AppControl frontend

💡 This simplifies DNS configuration and ensures consistency.

#### If You Are Deploying on a Different Domain

If you're deploying AppControl on another domain, make sure that:

-   x4b.<your-domain> and appcontrol.<your-domain> are correctly configured as DNS records

-   Both entries point to the public IP or ingress controller of your Kubernetes/OpenShift cluster

## 3. AppControl Platform Installer

This page explains how to deploy the AppControl platform and its required services using the interactive installation script: `install-appcontrol.sh`.

The script sets up everything automatically, including:

-   Helm registry authentication
-   Kubernetes namespace creation
-   JWT key generation and secret
-   Redis and RabbitMQ integration
-   SQL Server connection
-   Configuration injection via ConfigMap
-   Helm chart deployment for:
    -   `x4b-services`
    -   `appcontrol`

---

## ⚙️ Requirements

-   `oc` (OpenShift CLI)
-   `helm` (Helm 3+)
-   `openssl` (for JWT key generation)
-   Access to the Helm OCI registry (`x4bcontainerregistry.azurecr.io`)

---

## 🔐 SSL Configuration

AppControl supports HTTPS access to its web interfaces, and you have **two options** to enable SSL:

### Option 1: SSL via Kubernetes Ingress (Let's Encrypt)

If you are using an **Ingress controller** (e.g. nginx) inside your cluster:

-   AppControl is preconfigured to support Let's Encrypt
-   You **must create a `ClusterIssuer` named `letsencrypt-issuer`**
-   The certificate will be automatically generated and renewed by `cert-manager`

#### ✅ Example: Let's Encrypt ClusterIssuer (Staging)

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
    name: letsencrypt-issuer
spec:
    acme:
        server: https://acme-staging-v02.api.letsencrypt.org/directory
        email: your-email@yourdomain.com
        privateKeySecretRef:
            name: letsencrypt-account-key
        solvers:
            - http01:
                  ingress:
                      class: nginx
```

💡 Replace with the production ACME server for production use.

### Option 2: SSL via External Gateway or Load Balancer

If your architecture includes an external API gateway, reverse proxy, or cloud load balancer (e.g., Azure Front Door, AWS ELB, NGINX outside k8s):

You can terminate SSL there

Disable TLS in the Helm values:

```yaml
ingress:
  tls: false
  sslredirect: false
This lets you delegate SSL management to your gateway, while still using AppControl inside the cluster over HTTP.
```

Default Ingress Settings in the Script
The script generates:

```yaml
ingress:
    class: nginx
    tls: true
    sslredirect: true
```

This works out-of-the-box with cert-manager and letsencrypt-issuer.
If you're using an external gateway, update these settings before installation or edit appcontrol-values.yaml.

## 🧪 Inputs Prompted by the Script

| Input                          | Description                                        | Example               | Default                  |
| ------------------------------ | -------------------------------------------------- | --------------------- | ------------------------ |
| `MY_APPCONTROL_DOMAIN`         | Your domain (base DNS)                             | `mycompany.com`       | _required_               |
| Namespace                      | Kubernetes namespace for install                   | `appcontrol`          | Current namespace        |
| Helm registry credentials      | Used to authenticate to the OCI Helm registry      | `login / password`    | _required_               |
| SQL Server info                | Connection details to your SQL database            | `sql.prod.local` etc. | _required_               |
| Token salt                     | Salt used for JWT generation                       | Random base64 string  | _auto-generated_         |
| Redis host/port                | Redis service used by AppControl                   | `redis-service:6379`  | `redis-service:6379`     |
| RabbitMQ host/port/vhost/user  | RabbitMQ messaging broker used by X4B & AppControl | `rabbitmq`, `5672`    | Defaults + prompt values |
| Helm chart X4B Service version | Version of Helm chart to install                   | `40.6.0`              | `40.6.0`                 |
| Helm chart Appcontrol version  | Version of Helm chart to install                   | `90.3.0`              | `90.3.0`                 |

---

## 📂 Generated Files

| File                       | Purpose                                  |
| -------------------------- | ---------------------------------------- |
| `x4b-services-values.yaml` | Values for the `x4b-services` Helm chart |
| `appcontrol-values.yaml`   | Values for the `appcontrol` Helm chart   |

---

## 📦 What the Script Does

1. Detects or prompts for a Openshift namespace
2. Logs into the AppControl Helm OCI registry
3. Creates a `ConfigMap` for AppControl config files
4. Generates RSA keys and creates a JWT `Secret`
5. Generates 2 values files (`*.yaml`)
6. Installs:
    - `appcontrol-services` chart (X4B platform)
    - `appcontrol` chart (AppControl interface)

---

## 🟢 Usage

```bash
curl -sLO https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/install-appcontrol.sh
chmod +x install-appcontrol.sh
./install-appcontrol.sh
```

Follow the interactive prompts. The deployment takes just a few minutes.

✅ Result

## ✅ Once Installed

Depending on whether you enabled TLS during installation:

### 🔒 If TLS was enabled:

-   AppControl is available at **https://appcontrol.mycompany.com**
-   X4B backend is available at **https://x4b.mycompany.com**

### 🌐 If TLS was not enabled:

-   AppControl is available at **http://appcontrol.mycompany.com**
-   X4B backend is available at **http://x4b.mycompany.com**

### 👤 Accessing the Platform

After installation is complete, a **default administrator account** is created automatically:

-   **Username:** `admin`
-   **Password:** `KoordinatorAdmin`

You can log in to the AppControl web interface using this account.

> ⚠️ **Important:** For security reasons, it is strongly recommended to change the default password after your first login.

You can update the password directly from the **user settings page** inside the AppControl UI.

📎 Notes

-   Redis and RabbitMQ should be running in the cluster or externally accessible.

-   SSL and Ingress settings are pre-configured for a typical nginx setup.

-   Make sure your DNS entries are correctly pointed before accessing the web UI.
