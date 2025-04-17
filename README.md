# Coto Redis Helm Chart

This Helm chart deploys a Redis instance in Kubernetes for multiple environments (`dev`, `qa`, `preprod`, `prod`) using dynamic configuration. It includes storage, secrets, and autoscaling settings appropriate to each environment.

## 📦 What This Chart Includes
- Redis `Deployment` with environment-specific configuration
- EBS-backed `PersistentVolumeClaim` using the cost-effective `gp3` storage class
- Kubernetes `Service` to expose Redis within the cluster
- Optional `HorizontalPodAutoscaler` if enabled in values
- Kubernetes `Secret` for Redis password (instead of AWS Secrets Manager)

## 📁 File Structure
.
├── Chart.yaml
├── values.yaml
├── value-dev.yaml
├── value-qa.yaml
├── value-preprod.yaml
├── value-prod.yaml
├── templates/
│   ├── deployment.yaml
│   ├── service.yaml
│   ├── pvc.yaml
│   ├── hpa.yaml
│   ├── spc.yaml
│   └── NOTES.txt
└── deploy.sh

## 🚀 How to Deploy

1. Ensure one of the following namespaces exists in your cluster:
   - `dev`, `qa`, `preprod`, `prod`

2. Run the deployment script:
```bash
chmod +x deploy.sh
./deploy.sh
```

This script will:
- Detect the active namespace
- Prompt you for a Redis password
- Create a Kubernetes secret (`redis-secret`) with the password
- Apply the correct `value-<env>.yaml` file
- Deploy the chart with Helm

## 🔐 Redis Password Secret
- Stored as a native Kubernetes Secret (`redis-secret`)
- Mounted securely in the container

## 💼 Service Account & IRSA
- IRSA disabled for cost efficiency
- No IAM binding required

## ✅ Best Practices Followed
- `gp3` for EBS
- Secure secrets
- Env-specific resources and scaling

## 🔗 Access Redis From a Pod in Same Namespace
If you're deploying your application in the same namespace where Redis is installed (e.g., `preprod`), then you can access Redis using:

```
coto-redis-eks:6379
```

This works because the Helm `service.yaml` uses a predictable name:
```yaml
name: {{ .Chart.Name }}-eks
```

No need for FQDN or cross-namespace DNS. Just use the short name in your app’s config.

Example config:
```env
REDIS_HOST=coto-redis-eks
REDIS_PORT=6379
```

Redis will require the password that was entered during `deploy.sh` execution.
