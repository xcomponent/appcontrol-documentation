#!/bin/bash

set -e

echo "#=============================================================================="
echo "🧬 XComponent AppControl - Installation Script"
echo "# © 2025 Invivoo Software - All rights reserved"
echo "# ============================================================================="


if [ -f ".env" ]; then
    echo "Loading variables from .env..."
    set -o allexport
    source .env
    set +o allexport
fi


# === Detect current namespace ===
DEFAULT_NAMESPACE=$(oc config view --minify --output 'jsonpath={..namespace}')
read -rp "📛 Namespace to install AppControl [${NAMESPACE:-${DEFAULT_NAMESPACE:-appcontrol}}]: " input_namespace
NAMESPACE="${input_namespace:-${NAMESPACE:-${DEFAULT_NAMESPACE:-appcontrol}}}"

read -rp "📦 Helm chart X4B Services version [${CHART_X4B_SERVICES_VERSION:-50.9.0}]: " input_x4b_version
CHART_X4B_SERVICES_VERSION="${input_x4b_version:-${CHART_X4B_SERVICES_VERSION:-50.9.0}}"

read -rp "📦 Helm chart Appcontrol version [${CHART_APPCONTROL_VERSION:-90.3.0}]: " input_appcontrol_version
CHART_APPCONTROL_VERSION="${input_appcontrol_version:-${CHART_APPCONTROL_VERSION:-100.5.0}}"


read -rp "📬 RabbitMQ username [${RABBIT_USER:-}]: " input_rabbit_user
RABBIT_USER="${input_rabbit_user:-${RABBIT_USER:-}}"

read -rp "📬 RabbitMQ password [${RABBIT_PASSWORD:-}]: " input_rabbit_password
RABBIT_PASSWORD="${input_rabbit_password:-${RABBIT_PASSWORD:-}}"

read -rp "🔐 Redis password [${REDIS_PASSWORD:-}]: " input_redis_password
echo
REDIS_PASSWORD="${input_redis_password:-${REDIS_PASSWORD:-}}"

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
SQL_PASSWORD="${input_sql_password:-${SQL_PASSWORD:-}}"

# Generate default salt if not provided
DEFAULT_SALT=$(openssl rand -base64 32)
read -rp "🪙 Token salt [${TOKEN_SALT:-auto-generated}]: " input_token_salt
TOKEN_SALT="${input_token_salt:-${TOKEN_SALT:-$DEFAULT_SALT}}"

# === TLS prompt with detection ===
echo -e "\n🔐 TLS Configuration"

read -rp "Do you want to enable TLS ? [Y/n]: " ENABLE_TLS
ENABLE_TLS=${ENABLE_TLS:-Y}


echo "🧹 Removing previous installation of Redis and RabbitMQ in namespace '$NAMESPACE'..."

# Supprimer Redis
oc delete deployment redis -n "$NAMESPACE" --ignore-not-found
oc delete service redis -n "$NAMESPACE" --ignore-not-found
oc delete configmap redis-config -n "$NAMESPACE" --ignore-not-found
oc delete route redis -n "$NAMESPACE" --ignore-not-found

# Supprimer RabbitMQ
oc delete deployment rabbitmq -n "$NAMESPACE" --ignore-not-found
oc delete service rabbitmq -n "$NAMESPACE" --ignore-not-found
oc delete configmap rabbitmq-config -n "$NAMESPACE" --ignore-not-found
oc delete secret rabbitmq-secret -n "$NAMESPACE" --ignore-not-found
oc delete pvc -l app=rabbitmq -n "$NAMESPACE" --ignore-not-found
oc delete route rabbitmq -n "$NAMESPACE" --ignore-not-found

echo "⏳ Waiting for complete deletion of Redis and RabbitMQ..."

timeout=60
elapsed=0
interval=2

while true; do
  count=$(oc get pods -n "$NAMESPACE" --no-headers 2>/dev/null | grep -E 'redis|rabbitmq' | wc -l || true)

  if [[ "$count" -eq 0 ]]; then
    echo "✅ RabbitMQ and Redis pods have been removed."
    break
  fi

  if (( elapsed >= timeout )); then
    echo "⚠️ Timeout: Redis or RabbitMQ pods still present."
    oc get pods -n "$NAMESPACE" | grep -E 'redis|rabbitmq' || true
    break
  fi

  echo "⌛ Still waiting... ($count remaining)"
  sleep $interval
  elapsed=$((elapsed + interval))
done

echo "▶️ RabbitMq installation in namespace '$NAMESPACE'"

curl -fsSL https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/rabbitmq.yaml | \
  RABBITMQ_USER="$RABBITMQ_USER" RABBITMQ_PASS="$RABBITMQ_PASS" envsubst | \
  oc apply -n "$NAMESPACE" -f -


curl -fsSL https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/rabbitmq.yaml | \
  RABBITMQ_USER="$RABBITMQ_USER" RABBITMQ_PASS="$RABBITMQ_PASS" envsubst | \
  oc apply -n "$NAMESPACE" -f -

echo "⏳ Waiting for RabbitMQ Pod..."

timeout_seconds=180
elapsed=0
interval=3

while true; do
  pod=$(oc get pods -n "$NAMESPACE" -l app=rabbitmq -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

  if [[ -n "$pod" ]]; then
    status=$(oc get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null)
    ready=$(oc get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.containerStatuses[0].ready}' 2>/dev/null)

    if [[ "$status" == "Running" && "$ready" == "true" ]]; then
      echo "✅ RabbitMQ Pod Ready : $pod"
      break
    fi

    echo "⌛ Found Pod ($pod), waiting ... (status: $status, ready: $ready)"
  else
    echo "🔍 Waiting for RabbitMQ Pod ..."
  fi

  sleep $interval
  elapsed=$((elapsed + interval))

  if (( elapsed >= timeout_seconds )); then
    echo "❌ Timed out : RabbitMQ is not ready." >&2
    oc get pods -n "$NAMESPACE" -l app=rabbitmq
    exit 1
  fi
done

RABBIT_HOST="rabbitmq"
RABBIT_VHOST="my-vhost"


echo "▶️ Redis installation in namespace '$NAMESPACE'"

echo "🔐 Creating secret in namespace: $NAMESPACE"
oc delete secret redis-secret -n "$NAMESPACE" 2>/dev/null || true

cat <<EOF | oc apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: redis-secret
  namespace: ${NAMESPACE}
type: Opaque
stringData:
  redis.conf: |
    requirepass ${REDIS_PASSWORD}
EOF

echo "📦 Applying Redis deployment and service..."
cat <<EOF | oc apply -n "$NAMESPACE" -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: redis-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
    spec:
      containers:
        - name: redis
          image: redis:7
          args: ["redis-server", "/usr/local/etc/redis/redis.conf"]
          ports:
            - containerPort: 6379
          volumeMounts:
            - name: redis-config
              mountPath: /usr/local/etc/redis
              readOnly: true
            - name: redis-storage
              mountPath: /data
      volumes:
        - name: redis-config
          secret:
            secretName: redis-secret
        - name: redis-storage
          persistentVolumeClaim:
            claimName: redis-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: redis
spec:
  selector:
    app: redis
  ports:
    - protocol: TCP
      port: 6379
      targetPort: 6379
EOF

echo "⏳ Waiting for Redis pod to be ready..."

# Wait until Redis pod reaches 'Running' state
while true; do
  pod=$(oc get pods -n "$NAMESPACE" -l app=redis -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  status=$(oc get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null)

  if [[ "$status" == "Running" ]]; then
    echo "✅ Redis pod is running: $pod"
    break
  fi

  echo "⌛ Waiting... (status: ${status:-pending})"
  sleep 2
done

echo "📄 Streaming logs for Redis pod: $pod"
echo "------------------------------------"

# Stream logs and break when readiness message is found
oc logs -f pod/"$pod" -n "$NAMESPACE" | while read -r line; do
  echo "$line"
  if echo "$line" | grep -q "Ready to accept connections"; then
    echo "✅ Redis is ready (log confirmed)."
     pkill -P $$ oc  # ⬅️ tue uniquement le 'oc logs -f' enfant de ce script
    break  # ⬅️ Quitte seulement la boucle, pas le script
  fi
done


REDIS_HOST="redis"
REDIS_PORT=6379
REDIS_HOSTNAME="$REDIS_HOST:$REDIS_PORT"



AGENT_IMAGE=${AGENT_IMAGE:-xcomponent/appcontrol-agent:100.5-ubi8}

SECRET_NAME=regcred

oc delete secret "$SECRET_NAME" -n "$NAMESPACE" --ignore-not-found

if ! oc get secret "$SECRET_NAME" -n "$NAMESPACE" &>/dev/null; then
  echo "🔐 Creating dummy imagePullSecret '$SECRET_NAME' in namespace '$NAMESPACE'..."
  oc create secret generic "$SECRET_NAME" \
    -n "$NAMESPACE" \
    --dry-run=client -o yaml | oc apply -f -
else
  echo "ℹ️ Secret '$SECRET_NAME' already exists in namespace '$NAMESPACE'."
fi

SQL_CONNECTION_STRING_SERVICES="Server=$SQL_SERVER,1433;Initial Catalog=xc-appcontrol-services-db;User ID=$SQL_USER;Password=$SQL_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=300;"
SQL_CONNECTION_STRING_APPCONTROL="Server=$SQL_SERVER,1433;Initial Catalog=xc-appcontrol-db;User ID=$SQL_USER;Password=$SQL_PASSWORD;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=True;Connection Timeout=300;ConnectRetryCount=30"



EXTERNAL_URL="https://$MY_APPCONTROL_DOMAIN"


if [[ "$ENABLE_TLS" =~ ^[Yy]$ ]]; then
  TLS_ENABLED=true
  SSL_REDIRECT=true
else
  TLS_ENABLED=false
  SSL_REDIRECT=false
  EXTERNAL_URL="http://$MY_APPCONTROL_DOMAIN"
fi

APPS_EXTERNAL_URL="${EXTERNAL_URL}/apps"
AUTHENTICATION_URL="${EXTERNAL_URL}/authentication"
LOGIN_EXTERNAL_URL="${EXTERNAL_URL}/login"
AUTH_INTERNAL_URL="http://appcontrol-services-x4b-services-authentication-svc:8080"
REDIRECT_REGISTRATION_URL="${LOGIN_EXTERNAL_URL}/registration"

MY_SECRET_NAME="jwt-keys"
CONFIGMAP_NAME="appcontrol-config"
REPO="oci://x4bcontainerregistry.azurecr.io/helm"

# === Helm registry login ===
helm registry login x4bcontainerregistry.azurecr.io --username "$HELM_USERNAME" --password "$HELM_PASSWORD"

# === Create namespace ===
oc get namespace "$NAMESPACE" >/dev/null 2>&1 || oc create namespace "$NAMESPACE"

# === Create ConfigMap ===
echo "🧩 Creating AppControl config map..."
oc delete configmap "$CONFIGMAP_NAME" -n "$NAMESPACE" --ignore-not-found

applications_json=$(curl -fsSL https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/applications-template.json | sed "s|MY_APPCONTROL_DOMAIN|$EXTERNAL_URL|g")

services_json=$(curl -fsSL https://raw.githubusercontent.com/xcomponent/appcontrol-documentation/refs/heads/main/docs/config/services-template.json | sed "s|MY_APPCONTROL_DOMAIN|$EXTERNAL_URL|g")

oc create configmap "$CONFIGMAP_NAME" -n "$NAMESPACE" \
  --from-literal=applications.json="$applications_json" \
  --from-literal=services.json="$services_json"

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

mkdir -p generated

# === Generate x4b-services-values.yaml ===
cat <<EOF > generated/x4b-services-values.yaml
externalHostname: "${MY_APPCONTROL_DOMAIN}"
x4bSpecificDnszone: "${MY_APPCONTROL_DOMAIN}"
jwtSecretName: "${MY_SECRET_NAME}"
devSubDomain: ""
settings:
  appsServiceUrl: "${APPS_EXTERNAL_URL}"
  authenticationUrl: "${AUTHENTICATION_URL}"
sql:
  connectionString: "${SQL_CONNECTION_STRING_SERVICES}"
migrate:
  env:
    targets: 'X4B,xc-appcontrol-services-db||AppControl,xc-appcontrol-db'
ingress:
  enabled: false
  class: nginx
  tls: $TLS_ENABLED
  sslredirect: $SSL_REDIRECT
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
externalHostname: $MY_APPCONTROL_DOMAIN
redisConnectionString: "$REDIS_CONNECTION_STRING"
adminAccountList: "admin"
environmentName: "prod"
appControl:
  tokenSalt: "$TOKEN_SALT"
launcher:
  replicaCount: 1
  connectionString: "$SQL_CONNECTION_STRING_APPCONTROL"
api:
  replicaCount: 1
ingress:
  enabled: false
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
  commandconnectionString: "$SQL_CONNECTION_STRING_APPCONTROL"
agent:
  image: $AGENT_IMAGE
webapp:
  enableSms: false

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

echo "⏳ Waiting for migration pod to complete (prefix: appcontrol-services-x4b-services-migrate)..."

timeout_seconds=300
elapsed=0
interval=5

# Find the migration pod
while true; do
  migrate_pod=$(oc get pods -n "$NAMESPACE" --no-headers | awk '/^appcontrol-services-x4b-services-migrate/ {print $1; exit}')
  
  if [[ -n "$migrate_pod" ]]; then
    echo "🔍 Found pod: $migrate_pod"
    break
  fi

  if (( elapsed >= timeout_seconds )); then
    echo "❌ Timeout: migration pod not found."
    exit 1
  fi

  echo "⌛ Waiting for migration pod to appear..."
  sleep "$interval"
  elapsed=$((elapsed + interval))
done

elapsed=0
while true; do
  phase=$(oc get pod "$migrate_pod" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null)

  if [[ "$phase" == "Succeeded" ]]; then
    echo "✅ Migration pod completed successfully."
    break
  elif [[ "$phase" == "Failed" ]]; then
    echo "❌ Migration pod failed."
    oc logs "$migrate_pod" -n "$NAMESPACE"
    exit 1
  fi

  if (( elapsed >= timeout_seconds )); then
    echo "❌ Timeout: migration pod did not complete."
    oc describe pod "$migrate_pod" -n "$NAMESPACE"
    exit 1
  fi

  echo "⌛ Pod still running... (status: $phase)"
  sleep "$interval"
  elapsed=$((elapsed + interval))
done


echo "🚀 Installing AppControl..."
helm install appcontrol "$REPO/appcontrol" \
  --namespace "$NAMESPACE" \
  --version "$CHART_APPCONTROL_VERSION" \
  -f generated/appcontrol-values.yaml 

wait_for_all_pods_ready() {
  local namespace=${1:-default}
  local timeout_seconds=${2:-300}
  local interval_seconds=5
  local elapsed=0

  echo "⏳ Waiting for all pods in '$namespace' to be running and ready..."

  while true; do
    # List non-Completed pods
    pods=$(oc get pods -n "$namespace" --no-headers | grep -v 'Completed' || true)

    # Count pods not in 'Running'
    not_running=$(echo "$pods" | awk '$3 != "Running"' | wc -l)

    # Count pods whose containers are not all Ready (e.g. 1/1, 2/2)
    containers_not_ready=$(echo "$pods" | awk '{print $2}' | grep -vE '^([0-9]+)/\1$' | wc -l)

    if [[ "$not_running" -eq 0 && "$containers_not_ready" -eq 0 ]]; then
      echo "✅ All pods are running and ready."
      return 0
    fi

    if [[ "$elapsed" -ge "$timeout_seconds" ]]; then
      echo "❌ Timeout: Some pods are not ready:"
      oc get pods -n "$namespace"
      return 1
    fi

    echo "⌛ Still waiting... ($not_running not running, $containers_not_ready not ready)"
    sleep "$interval_seconds"
    elapsed=$((elapsed + interval_seconds))
  done
}


# Juste avant les routes :
wait_for_all_pods_ready "$NAMESPACE" 300 || exit 1

echo "🔁 Removing existing routes..."
ROUTES=(
  appcontrol-api
  appcontrol-hermes-svc
  appcontrol-services-x4b-services-apps-svc
  appcontrol-services-x4b-services-authentication-svc
  appcontrol-services-x4b-services-login-clearexpired
  appcontrol-services-x4b-services-login-svc
  appcontrol-services-x4b-services-settings-svc
  appcontrol-webapp
  route-agentmanagerbridge
)

for route in "${ROUTES[@]}"; do
  oc delete route "$route" -n "$NAMESPACE" --ignore-not-found
done


echo "🚀 Creation of new routes..."

cat <<EOF | oc apply -f -
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: appcontrol-api
  annotations:
    haproxy.router.openshift.io/rewrite-target: /
spec:
  host: ${MY_APPCONTROL_DOMAIN}
  path: /core
  to:
    kind: Service
    name: appcontrol-api
  port:
    targetPort: 7890
  tls:
    termination: edge
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: appcontrol-hermes-svc
  annotations:
    haproxy.router.openshift.io/rewrite-target: /
spec:
  host: ${MY_APPCONTROL_DOMAIN}
  path: /notif
  to:
    kind: Service
    name: appcontrol-hermes-svc
  port:
    targetPort: 5500
  tls:
    termination: edge
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: appcontrol-services-x4b-services-apps-svc
  annotations:
    haproxy.router.openshift.io/rewrite-target: /
spec:
  host: ${MY_APPCONTROL_DOMAIN}
  path: /apps
  to:
    kind: Service
    name: appcontrol-services-x4b-services-apps-svc
  port:
    targetPort: 8080
  tls:
    termination: edge
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: appcontrol-services-x4b-services-authentication-svc
  annotations:
    haproxy.router.openshift.io/rewrite-target: /
spec:
  host: ${MY_APPCONTROL_DOMAIN}
  path: /authentication
  to:
    kind: Service
    name: appcontrol-services-x4b-services-authentication-svc
  port:
    targetPort: 8080
  tls:
    termination: edge
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: appcontrol-services-x4b-services-login-clearexpired
  annotations:
    haproxy.router.openshift.io/rewrite-target: /
spec:
  host: ${MY_APPCONTROL_DOMAIN}
  path: /authentication/api/RefreshTokens/ClearExpired
  to:
    kind: Service
    name: appcontrol-services-x4b-services-login-svc
  port:
    targetPort: 8080
  tls:
    termination: edge
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: appcontrol-services-x4b-services-login-svc
spec:
  host: ${MY_APPCONTROL_DOMAIN}
  path: /login
  to:
    kind: Service
    name: appcontrol-services-x4b-services-login-svc
  port:
    targetPort: 8080
  tls:
    termination: edge
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: appcontrol-services-x4b-services-settings-svc
spec:
  host: ${MY_APPCONTROL_DOMAIN}
  path: /settings
  to:
    kind: Service
    name: appcontrol-services-x4b-services-settings-svc
  port:
    targetPort: 8080
  tls:
    termination: edge
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: appcontrol-webapp
  annotations:
    haproxy.router.openshift.io/rewrite-target: /
spec:
  host: ${MY_APPCONTROL_DOMAIN}
  path: /
  to:
    kind: Service
    name: appcontrol-webapp
  port:
    targetPort: 8080
  tls:
    termination: edge
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: route-agentmanagerbridge
  annotations:
    haproxy.router.openshift.io/rewrite-target: /
    haproxy.router.openshift.io/timeout: 2h
    haproxy.router.openshift.io/balance: source
spec:
  host: ${MY_APPCONTROL_DOMAIN}
  path: /agentmanager
  to:
    kind: Service
    name: appcontrol-agentmanagerbridge
  port:
    targetPort: 8080
  tls:
    termination: edge
EOF

echo "✅ Routes are successfully created for the domain : ${MY_APPCONTROL_DOMAIN}"

echo "🔐 Creating SQL credentials secret..."

oc delete secret sql-credentials -n "$NAMESPACE" --ignore-not-found

oc create secret generic sql-credentials -n "$NAMESPACE" \
  --from-literal=sql-server="$SQL_SERVER" \
  --from-literal=sql-user="$SQL_USER" \
  --from-literal=sql-password="$SQL_PASSWORD"

echo "🕒 Creating CronJob to call SQL status page stored procedure every hour..."

oc apply -n "$NAMESPACE" -f - <<EOF
apiVersion: batch/v1
kind: CronJob
metadata:
  name: call-sql-statuspageproc-hourly
spec:
  schedule: "0 * * * *"  # every hour
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: sql-job
            image: mcr.microsoft.com/mssql-tools
            command: ["/bin/sh", "-c"]
            args:
              - >
                /opt/mssql-tools/bin/sqlcmd -S tcp:\$(SQL_SERVER),1433
                -U \$(SQL_USER)
                -P "\$(SQL_PASSWORD)"
                -d xc-appcontrol-db
                -Q "EXEC [dbo].[FillTimesUpDataToDay];"
            env:
            - name: SQL_SERVER
              valueFrom:
                secretKeyRef:
                  name: sql-credentials
                  key: sql-server
            - name: SQL_USER
              valueFrom:
                secretKeyRef:
                  name: sql-credentials
                  key: sql-user
            - name: SQL_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: sql-credentials
                  key: sql-password
            - name: ACCEPT_EULA
              value: "Y"
          restartPolicy: Never
EOF



echo "✅ AppControl platform successfully deployed!"
