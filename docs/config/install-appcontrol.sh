#!/bin/bash

set -e

echo "🔧 AppControl Interactive Installer"

# === Detect current namespace ===
DEFAULT_NAMESPACE=$(oc config view --minify --output 'jsonpath={..namespace}')
read -rp "📛 Namespace to install AppControl [${DEFAULT_NAMESPACE:-appcontrol}]: " NAMESPACE
NAMESPACE=${NAMESPACE:-${DEFAULT_NAMESPACE:-appcontrol}}

# === Prompt user input ===
read -rp "🌐 Enter your main domain (e.g., mycompany.com): " MY_APPCONTROL_DOMAIN
read -rp "🔑 Helm registry username: " HELM_USERNAME
read -rp "🔑 Helm registry password: " HELM_PASSWORD

echo "🗃 SQL Server configuration:"
read -rp "  - Server: " SQL_SERVER
read -rp "  - User: " SQL_USER
read -srp "  - Password: " SQL_PASSWORD
echo
SQL_CONNECTION_STRING_SERVICES="Server=$SQL_SERVER;Database=xc-x4b-db;User ID=$SQL_USER;Password=$SQL_PASSWORD;"
SQL_CONNECTION_STRING_APPCONTROL="Server=$SQL_SERVER;Database=xc-appcontrol-db;User ID=$SQL_USER;Password=$SQL_PASSWORD;"

# Generate default salt
DEFAULT_SALT=$(openssl rand -base64 32)
read -rp "🪙 Token salt [auto-generated]: " TOKEN_SALT
TOKEN_SALT=${TOKEN_SALT:-$DEFAULT_SALT}

read -rp "🧠 Redis hostname [redis-service]: " REDIS_HOST
REDIS_HOST=${REDIS_HOST:-redis-service}
read -rp "🔢 Redis port [6379]: " REDIS_PORT
REDIS_PORT=${REDIS_PORT:-6379}
REDIS_HOSTNAME="$REDIS_HOST:$REDIS_PORT"

read -rp "📬 RabbitMQ hostname [rabbitmq]: " RABBIT_HOST
RABBIT_HOST=${RABBIT_HOST:-rabbitmq}
read -rp "📬 RabbitMQ username: " RABBIT_USER
read -rp "📬 RabbitMQ password: " RABBIT_PASSWORD
read -rp "📬 RabbitMQ virtual host [/]:" RABBIT_VHOST
RABBIT_VHOST=${RABBIT_VHOST:-/}

read -rp "📦 Helm chart X4B Services version [40.6.0]: " CHART_X4B_SERVICES_VERSION
CHART_X4B_SERVICES_VERSION=${CHART_X4B_SERVICES_VERSION:-40.6.0}

read -rp "📦 Helm chart Appcontrol version [90.3.0]: " CHART_APPCONTROL_VERSION
CHART_APPCONTROL_VERSION=${CHART_APPCONTROL_VERSION:-90.3.0}

# === TLS prompt with detection ===
echo -e "\n🔐 TLS Configuration (Let's Encrypt via cert-manager)"
CERT_MANAGER_OK=$(kubectl get pods -n cert-manager --no-headers 2>/dev/null | wc -l)
ISSUER_EXISTS=$(kubectl get clusterissuer letsencrypt-issuer --no-headers 2>/dev/null | wc -l)

read -rp "Do you want to enable TLS with Let's Encrypt? [Y/n]: " ENABLE_TLS
ENABLE_TLS=${ENABLE_TLS:-Y}

if [[ "$ENABLE_TLS" =~ ^[Yy]$ ]]; then
  TLS_ENABLED=true
  SSL_REDIRECT=true

  if [[ "$CERT_MANAGER_OK" -eq 0 || "$ISSUER_EXISTS" -eq 0 ]]; then
    echo "⚠️  Warning: cert-manager or letsencrypt-issuer not detected."
    echo "   TLS will be enabled in the values.yaml but you must configure it in your cluster manually."
    read -rp "Continue with TLS enabled? [y/N]: " CONTINUE_TLS
    [[ "$CONTINUE_TLS" =~ ^[Yy]$ ]] || exit 1
  fi
else
  TLS_ENABLED=false
  SSL_REDIRECT=false
fi

MY_SECRET_NAME="jwt-keys"
CONFIGMAP_NAME="appcontrol-config"
REPO="oci://x4bcontainerregistry.azurecr.io/helm"

APPS_EXTERNAL_URL="https://x4b.$MY_APPCONTROL_DOMAIN/apps"
LOGIN_EXTERNAL_URL="https://x4b.$MY_APPCONTROL_DOMAIN/login"
AUTH_INTERNAL_URL="http://x4b-services-authentication-svc:8080"

# === Confirmation ===
echo -e "\n📋 Summary:"
echo "Namespace: $NAMESPACE"
echo "Domain: $MY_APPCONTROL_DOMAIN"
echo "Redis: $REDIS_HOSTNAME"
echo "RabbitMQ: $RABBIT_USER@$RABBIT_HOST (vhost=$RABBIT_VHOST)"
read -rp "✅ Proceed with installation? [y/N]: " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

# === Helm registry login ===
helm registry login x4bcontainerregistry.azurecr.io --username "$HELM_USERNAME" --password "$HELM_PASSWORD"

# === Create namespace ===
oc get namespace "$NAMESPACE" >/dev/null 2>&1 || oc create namespace "$NAMESPACE"

# === Create ConfigMap ===
echo "🧩 Creating AppControl config map..."
oc delete configmap "$CONFIGMAP_NAME" -n "$NAMESPACE" --ignore-not-found
oc create configmap "$CONFIGMAP_NAME" -n "$NAMESPACE" \
  --from-literal=applications.json="$(curl -s https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/applications-template.json | sed "s/MY_APPCONTROL_DOMAIN/$MY_APPCONTROL_DOMAIN/g")" \
  --from-literal=services.json="$(curl -s https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/services-template.json | sed "s/MY_APPCONTROL_DOMAIN/$MY_APPCONTROL_DOMAIN/g")"

# === Generate JWT keys ===
echo "🔐 Creating JWT secret..."
openssl genpkey -algorithm RSA -out jwt-private.pem
openssl rsa -pubout -in jwt-private.pem -out jwt-public.pem

oc delete secret "$MY_SECRET_NAME" -n "$NAMESPACE" --ignore-not-found
oc create secret generic "$MY_SECRET_NAME" -n "$NAMESPACE" \
  --from-file=jwt-private.pem=jwt-private.pem \
  --from-file=jwt-public.pem=jwt-public.pem
rm jwt-private.pem jwt-public.pem

mkdir -p generated

# === Generate x4b-services-values.yaml ===
cat <<EOF > generated/x4b-services-values.yaml
externalHostname: x4b.$MY_APPCONTROL_DOMAIN
jwtSecretName: $MY_SECRET_NAME
sql:
  connectionString: "$SQL_CONNECTION_STRING_SERVICES"
apps:
  appsConfigMapName: "$CONFIGMAP_NAME"
EOF

# === Generate appcontrol-values.yaml ===
cat <<EOF > generated/appcontrol-values.yaml
externalHostname: appcontrol.$MY_APPCONTROL_DOMAIN
appControl:
  tokenSalt: "$TOKEN_SALT"
  adminAccountList: ""
  environmentName: "prod"
  redisConnectionString: "$REDIS_HOSTNAME"
launcher:
  replicaCount: 1
api:
  replicaCount: 1
ingress:
  class: nginx
  tls: $TLS_ENABLED
  sslredirect: $SSL_REDIRECT
dbaccess:
  useDatabase: true
  connectionString: "$SQL_CONNECTION_STRING_APPCONTROL"
x4b:
  appsExternalUrl: "$APPS_EXTERNAL_URL"
  loginExternalUrl: "$LOGIN_EXTERNAL_URL"
  authenticationInternalUrl: "$AUTH_INTERNAL_URL"
rabbitmq:
  hostname: "$RABBIT_HOST"
  username: "$RABBIT_USER"
  password: "$RABBIT_PASSWORD"
  virtualHost: "$RABBIT_VHOST"
EOF

# === Deploy Helm charts ===
echo "🚀 Installing x4b-services..."
helm install appcontrol-services "$REPO/appcontrol-services" \
  --namespace "$NAMESPACE" \
  --version "$CHART_X4B_SERVICES_VERSION" \
  -f generated/x4b-services-values.yaml

echo "🚀 Installing AppControl..."
helm install appcontrol "$REPO/appcontrol" \
  --namespace "$NAMESPACE" \
  --version "$CHART_APPCONTROL_VERSION" \
  -f generated/appcontrol-values.yaml

echo "✅ AppControl platform successfully deployed!"
