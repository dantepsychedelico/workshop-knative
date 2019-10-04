#!/bin/bash
## Create service account and create a key for service account

gcloud iam service-accounts create workshop-knative --display-name=workshop-knative
export SA_MAIL=$(gcloud iam service-accounts list --format=json | jq -r '.[]|select(.displayName == "workshop-knative")|.email')
gcloud iam service-accounts keys create --iam-account=$SA_MAIL google-sa-key.json
