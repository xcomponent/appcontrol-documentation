#!/bin/bash

# Default values
: "${REDIS_PASSWORD:=appcontrolpwd}"
: "${NAMESPACE:=$(oc config view --minify --output 'jsonpath={..namespace}')}"

if [[ -z "$NAMESPACE" ]]; then
  echo "❌ No namespace set. Please run: export NAMESPACE=my-namespace"
  exit 1
fi

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

echo "✅ Redis deployed successfully in namespace '$NAMESPACE'."
echo "⏳ Waiting for Redis pod to be ready..."
while true; do
  pod=$(oc get pods -n "$NAMESPACE" -l app=redis -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
  status=$(oc get pod "$pod" -n "$NAMESPACE" -o jsonpath='{.status.phase}' 2>/dev/null)
  if [[ "$status" == "Running" ]]; then
    echo "✅ Redis pod is running: $pod"
    break
  fi
  echo "⌛ Waiting... (status: $status)"
  sleep 2
done

echo "📄 Displaying logs for pod $pod:"
echo "------------------------------------"
trap "echo -e '\n🛑 Log stream interrupted.'; exit 0" SIGINT
oc logs -f pod/"$pod" -n "$NAMESPACE"

echo -e "\n✅ Installation complete."
exit 0
