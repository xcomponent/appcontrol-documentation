# AppControl Installation Guide for OpenShift

## 1. Introduction

This guide describes the updated installation process for AppControl on an OpenShift cluster. It uses a **single script** (`install-appcontrol.sh`) to deploy all components, including Redis and RabbitMQ, which are installed automatically. DNS configuration has also been simplified: only **one domain** is required.

> ✅ The `install-appcontrol.sh` script has been tested successfully on **Red Hat OpenShift Sandbox**, a free, managed OpenShift environment provided by Red Hat.
>
> If you're new to OpenShift, we recommend using the sandbox to try AppControl with minimal setup:
> 🔗 https://developers.redhat.com/developer-sandbox

## 2. Requirements

### 2.1 OpenShift Cluster

Ensure that you have an OpenShift cluster with a dedicated project (namespace) for deploying AppControl.

To create the namespace if it does not exist:

```sh
oc new-project appcontrol
```

### 2.2 OpenShift Router

OpenShift’s native **Route** mechanism is used to expose services — no additional ingress controller is required.

### 2.3 SQL Server Database

AppControl requires a **Microsoft SQL Server** database (2017 or newer).

Example connection string (prompted during installation):

```txt
Server=tcp:MY_SERVER_IP,1433;Initial Catalog=MYDATABASE;
Persist Security Info=False;User ID=USERID;Password=PASSWORD;
MultipleActiveResultSets=False;Encrypt=True;
TrustServerCertificate=False;Connection Timeout=30;
```

> 📝 Note: SQL Server is not bundled with the install script. If you need to deploy it inside OpenShift, refer to Microsoft’s official workshop:  
> 🔗 [Deploy SQL Server on OpenShift – Microsoft Workshop](https://github.com/microsoft/sqlworkshops-sqlonopenshift/blob/master/sqlonopenshift/01_Deploy.md)

### 2.4 Tools Required

-   `oc` (OpenShift CLI)
-   `helm` (version 3 or above)
-   `openssl` (for generating JWT secrets)

## 3. Installation Overview

The `install-appcontrol.sh` script automates the full deployment of AppControl. It:

-   Authenticates to the Helm registry
-   Creates namespace (if needed)
-   Installs Redis and RabbitMQ
-   Creates required Secrets and ConfigMaps
-   Generates JWT keys
-   Deploys Helm charts for `x4b-services` and `appcontrol`

### ⚙️ .env File for Default Values

A `.env` file can be used to predefine environment variables such as domain, SQL connection string, or Helm registry credentials. These values are picked up by the script.

Example:

```env
MY_APPCONTROL_DOMAIN=mydomain.com
HELM_USERNAME=
HELM_PASSWORD=
SQL_SERVER=
SQL_USER=
SQL_PASSWORD=
REDIS_PASSWORD=appcontrolpwd
RABBIT_USER=admin
RABBIT_PASSWORD=admin123
CHART_X4B_SERVICES_VERSION=50.6.0
CHART_APPCONTROL_VERSION=90.9.0
AGENT_IMAGE=xcomponent/appcontrol-agent:90.7-ubi8
```

## 4. DNS Configuration

You only need **one base domain** (e.g. `mycompany.com`).

Ensure these are pointed to your OpenShift public route endpoint.

## 5. Script Usage

Download and execute:

```sh
curl -sLO https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/install-appcontrol.sh
chmod +x install-appcontrol.sh
./install-appcontrol.sh
```

Before launching the script, you can optionally create a .env file in the same directory as install-appcontrol.sh to predefine values that will be used during installation. This file allows you to automate and reuse configurations without manually entering them each time.

The script will prompt for:

-   Domain name
-   Namespace (or use current)
-   Helm credentials
-   SQL connection
-   Redis and RabbitMQ info

Defaults are provided where possible. Redis and RabbitMQ are now installed **automatically**.

## 6. TLS / HTTPS Access

Routes created by the script use OpenShift’s native Route system.

You can:

-   Use OpenShift-managed TLS
-   Terminate SSL externally (e.g., at Azure Front Door)

Example if TLS enabled:

-   AppControl UI: https://mycompany.com

## 7. Default Admin Access

After install, log in using:

-   **Username:** `admin`
-   **Password:** `KoordinatorAdmin`

> ⚠️ Change this password immediately after login via the AppControl user administration page.

## 8. Summary

-   One unified script: `install-appcontrol.sh`
-   Redis and RabbitMQ installed automatically
-   DNS simplified: only 1 domain needed
-   Uses OpenShift native Routes (no ingress)
-   Configuration handled via `.env` or interactive prompts
-   Helm charts deployed: `x4b-services` and `appcontrol`

---

Need help? Contact the AppControl team or consult the [documentation site](https://github.com/xcomponent/appcontrol-documentation).
