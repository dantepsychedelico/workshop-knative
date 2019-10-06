# Save money by stopping and starting K8S pools on schedule

## Create a service account

```
gcloud iam service-accounts create workshop-knative --display-name=workshop-knative
```

## Create a private key for the service account

```
export SA_MAIL=$(gcloud iam service-accounts list --format=json | jq -r '.[]|select(.displayName == "workshop-knative")|.email')
gcloud iam service-accounts keys create --iam-account=$SA_MAIL google-sa-key.json
```

### Add Service Account to IAM member

[[https://console.cloud.google.com/iam-admin/iam](https://console.cloud.google.com/iam-admin/iam)

- Add Roles `Kubernetes Engine Cluster Admin`, `Service Account User`, `Compute Load Balancer Admin, Cloud Run Invoker`
