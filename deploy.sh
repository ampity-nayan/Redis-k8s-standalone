#!/bin/bash

set -euo pipefail

CHART_DIR="$(dirname "$0")"
RELEASE_NAME="coto-redis"
ENVS=(prod preprod qa dev)

# Get available namespaces
NAMESPACES=$(kubectl get ns -o jsonpath='{.items[*].metadata.name}')

for ENV in "${ENVS[@]}"; do
  if echo "$NAMESPACES" | grep -qw "$ENV"; then
    VALUES_FILE="$CHART_DIR/value-$ENV.yaml"
    if [[ -f "$VALUES_FILE" ]]; then
      echo "✅ Environment detected: $ENV"

      # Ask for Redis password
      read -s -p "🔐 Enter Redis password: " REDIS_PASSWORD
      echo

      # Create Kubernetes secret
      kubectl create secret generic redis-secret         --namespace "$ENV"         --from-literal=REDIS_PASSWORD="$REDIS_PASSWORD"         --dry-run=client -o yaml | kubectl apply -f -

      echo "✅ Redis password secret created."
      echo "🚀 Deploying Helm chart..."

      helm upgrade --install "$RELEASE_NAME" "$CHART_DIR"         --namespace "$ENV"         -f "$VALUES_FILE"         --create-namespace

      echo "✅ Deployment complete."
      exit 0
    else
      echo "⚠️  Values file not found: $VALUES_FILE"
    fi
  fi
done

echo "❌ No known environment namespaces (prod, preprod, qa, dev) found in cluster."
echo "ℹ️  Please create one of the namespaces or provide a matching values file."
exit 1
