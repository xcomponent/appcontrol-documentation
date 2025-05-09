#!/bin/bash

set -e

if [ -f ".env" ]; then
    echo "Loading variables from .env..."
    set -o allexport
    source .env
    set +o allexport
fi

echo "🔧 AppControl Interactive Installer"

# === Detect current namespace ===
DEFAULT_NAMESPACE=$(oc config view --minify --output 'jsonpath={..namespace}')
read -rp "📛 Namespace to install AppControl [${NAMESPACE:-${DEFAULT_NAMESPACE:-appcontrol}}]: " input_namespace
NAMESPACE="${input_namespace:-${NAMESPACE:-${DEFAULT_NAMESPACE:-appcontrol}}}"

# === Prompt user input ===
read -rp "🌐 Enter your main domain (e.g., mycompany.com) [${MY_APPCONTROL_DOMAIN:-}]: " input_domain
MY_APPCONTROL_DOMAIN="${input_domain:-${MY_APPCONTROL_DOMAIN:-}}"

read -rp "🔑 Helm registry username [${HELM_USERNAME:-}]: " input_helm_user
HELM_USERNAME="${input_helm_user:-${HELM_USERNAME:-}}"

read -rp "🔑 Helm registry password [${HELM_PASSWORD:-}]: " input_helm_pass
HELM_PASSWORD="${input_helm_pass:-${HELM_PASSWORD:-}}"

echo "🗃 SQL Server configuration:"
read -rp "  - Server [${SQL_SERVER:-}]: " input_sql_server
SQL_SERVER="${input_sql_server:-${SQL_SERVER:-}}"

read -rp "  - User [${SQL_USER:-}]: " input_sql_user
SQL_USER="${input_sql_user:-${SQL_USER:-}}"

read -rp "  - Password [${SQL_PASSWORD:-}]: " input_sql_password
echo
SQL_PASSWORD="${input_sql_password:-${SQL_PASSWORD:-}}"

SQL_CONNECTION_STRING_SERVICES="Server=$SQL_SERVER,1433;Initial Catalog=xc-x4b-db;User ID=$SQL_USER;Password=$SQL_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"
SQL_CONNECTION_STRING_APPCONTROL="Server=$SQL_SERVER,1433;Initial Catalog=xc-appcontrol-db;User ID=$SQL_USER;Password=$SQL_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=300;ConnectRetryCount=30"


# Generate default salt if not provided
DEFAULT_SALT=$(openssl rand -base64 32)
read -rp "🪙 Token salt [${TOKEN_SALT:-auto-generated}]: " input_token_salt
TOKEN_SALT="${input_token_salt:-${TOKEN_SALT:-$DEFAULT_SALT}}"

read -rp "🧠 Redis hostname [${REDIS_HOST:-redis}]: " input_redis_host
REDIS_HOST="${input_redis_host:-${REDIS_HOST:-redis}}"

read -rp "🔢 Redis port [${REDIS_PORT:-6379}]: " input_redis_port
REDIS_PORT="${input_redis_port:-${REDIS_PORT:-6379}}"

REDIS_HOSTNAME="$REDIS_HOST:$REDIS_PORT"

read -rp "🔐 Redis password [${REDIS_PASSWORD:-}]: " input_redis_password
echo
REDIS_PASSWORD="${input_redis_password:-${REDIS_PASSWORD:-}}"

read -rp "📬 RabbitMQ hostname [${RABBIT_HOST:-rabbitmq}]: " input_rabbit_host
RABBIT_HOST="${input_rabbit_host:-${RABBIT_HOST:-rabbitmq}}"

read -rp "📬 RabbitMQ username [${RABBIT_USER:-}]: " input_rabbit_user
RABBIT_USER="${input_rabbit_user:-${RABBIT_USER:-}}"

read -rp "📬 RabbitMQ password [${RABBIT_PASSWORD:-}]: " input_rabbit_password
RABBIT_PASSWORD="${input_rabbit_password:-${RABBIT_PASSWORD:-}}"

read -rp "📬 RabbitMQ virtual host [${RABBIT_VHOST:-/}]: " input_rabbit_vhost
RABBIT_VHOST="${input_rabbit_vhost:-${RABBIT_VHOST:-/}}"

read -rp "📦 Helm chart X4B Services version [${CHART_X4B_SERVICES_VERSION:-40.6.0}]: " input_x4b_version
CHART_X4B_SERVICES_VERSION="${input_x4b_version:-${CHART_X4B_SERVICES_VERSION:-40.6.0}}"

read -rp "📦 Helm chart Appcontrol version [${CHART_APPCONTROL_VERSION:-90.3.0}]: " input_appcontrol_version
CHART_APPCONTROL_VERSION="${input_appcontrol_version:-${CHART_APPCONTROL_VERSION:-90.3.0}}"

# === TLS prompt with detection ===
echo -e "\n🔐 TLS Configuration (Let's Encrypt via cert-manager)"
CERT_MANAGER_OK=$(kubectl get pods -n cert-manager --no-headers 2>/dev/null | wc -l)
ISSUER_EXISTS=$(kubectl get clusterissuer letsencrypt-issuer --no-headers 2>/dev/null | wc -l)

read -rp "Do you want to enable TLS with Let's Encrypt? [Y/n]: " ENABLE_TLS
ENABLE_TLS=${ENABLE_TLS:-Y}

EXTERNAL_URL="https://x4b.$MY_APPCONTROL_DOMAIN/"


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
  EXTERNAL_URL="http://x4b.$MY_APPCONTROL_DOMAIN/"
fi

APPS_EXTERNAL_URL="${EXTERNAL_URL}apps"
AUTHENTICATION_URL="${EXTERNAL_URL}authentication"
LOGIN_EXTERNAL_URL="${EXTERNAL_URL}login"
AUTH_INTERNAL_URL="http://x4b-services-authentication-svc:8080"
REDIRECT_REGISTRATION_URL="${LOGIN_EXTERNAL_URL}/registration"

MY_SECRET_NAME="jwt-keys"
CONFIGMAP_NAME="appcontrol-config"
REPO="oci://x4bcontainerregistry.azurecr.io/helm"

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

REDIS_CONNECTION_STRING="${REDIS_HOSTNAME}"
if [[ -n "$REDIS_PASSWORD" ]]; then
  REDIS_CONNECTION_STRING="${REDIS_CONNECTION_STRING},password=${REDIS_PASSWORD}"
fi

echo "REDIS_CONNECTION_STRING: $REDIS_CONNECTION_STRING"
mkdir -p generated

# === Generate x4b-services-values.yaml ===
cat <<EOF > generated/x4b-services-values.yaml
externalHostname: "x4b.${MY_APPCONTROL_DOMAIN}"
x4bSpecificDnszone: "x4b.${MY_APPCONTROL_DOMAIN}"
jwtSecretName: "${MY_SECRET_NAME}"
pullSecretName: ""
devSubDomain: ""
settings:
  appsServiceUrl: "${APPS_EXTERNAL_URL}"
  authenticationUrl: "${AUTHENTICATION_URL}"
sql:
  connectionString: "${SQL_CONNECTION_STRING_SERVICES}"
apps:
  appsConfigMapName: "${CONFIGMAP_NAME}"
  serverRemoteUrl: "${EXTERNAL_URL}"
authentication:
  OtlpCollectorAddr: ''
  serverRemoteUrl: "${EXTERNAL_URL}"
  redirectRegistrationUrl: "${REDIRECT_REGISTRATION_URL}"
  loginPageUrl: "${LOGIN_EXTERNAL_URL}"
  secretName: $MY_SECRET_NAME
EOF

# === Generate appcontrol-values.yaml ===
cat <<EOF > generated/appcontrol-values.yaml
externalHostname: appcontrol.$MY_APPCONTROL_DOMAIN
redisConnectionString: "$REDIS_CONNECTION_STRING"
pullSecretName: ""
appControl:
  tokenSalt: "$TOKEN_SALT"
  adminAccountList: ""
  environmentName: "prod"
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
  user: "$RABBIT_USER"
  password: "$RABBIT_PASSWORD"
  vhost: "$RABBIT_VHOST"
restartPolicy:
  namespace: $NAMESPACE
  enabled: false
  schedule: "0 */6 * * *"
healthcheckhub:
  enabled: false

EOF

uninstall_if_exists() {
  local release=$1
  if helm status "$release" -n "$NAMESPACE" &>/dev/null; then
    echo "⛔ Uninstalling existing release: $release"
    helm uninstall "$release" -n "$NAMESPACE"
  fi
}

echo "🔍 Checking for existing releases..."
uninstall_if_exists "appcontrol-services"
uninstall_if_exists "appcontrol"

# === Deploy Helm charts ===
echo "🚀 Installing x4b-services..."
helm install appcontrol-services "$REPO/x4b-services" \
  --namespace "$NAMESPACE" \
  --version "$CHART_X4B_SERVICES_VERSION" \
  -f generated/x4b-services-values.yaml 

echo "🚀 Installing AppControl..."
helm install appcontrol "$REPO/appcontrol" \
  --namespace "$NAMESPACE" \
  --version "$CHART_APPCONTROL_VERSION" \
  -f generated/appcontrol-values.yaml 

echo "✅ AppControl platform successfully deployed!"
