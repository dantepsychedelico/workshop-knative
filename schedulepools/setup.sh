#!/bin/bash
## Create service account and create a key for service account

export SERVICE_ACCOUNT='workshop-knative'
export REPO="gcr.io/zac-chung-dev"

function get_sa_mail() {
    echo $(gcloud iam service-accounts list --format=json | jq -r '.[]|select(.displayName == "'$SERVICE_ACCOUNT'")|.email')
}
function get_run_url() {
    echo $(gcloud alpha run routes list --platform=managed --region='asia-northeast1' --format json | jq -r '.[]|select(.metadata.name == "workshop-knative-node-pool")|.status.url')
}
case $1 in
    create-sa)
        gcloud iam service-accounts create $SERVICE_ACCOUNT \
            --display-name=$SERVICE_ACCOUNT
        ;;
    create-sa-key)
        gcloud iam service-accounts keys create --iam-account=$(get_sa_mail) google-sa-key.json
        ;;
    create-k8s-auth)
        kubectl create clusterrolebinding cluster-view --clusterrole view --user $(get_sa_mail)
        ;;
    build)
        DOCKER_BUILDKIT=1 docker build -t ${REPO}/zac-chung-workshop-knative .
        ;;
    gcr-login)
        gcloud auth configure-docker
        ;;
    gcr-push)
        docker push ${REPO}/zac-chung-workshop-knative
        ;;
    deploy)
        gcloud alpha run deploy workshop-knative-node-pool \
            --image=${REPO}/zac-chung-dev-ops \
            --memory=128Mi \
            --platform=managed \
            --set-env-vars=GCP_PROJECT_ID='zac-chung-dev' \
            --set-env-vars=GCP_ZONE='asia-east1-a' \
            --set-env-vars=GCP_REGION='asia-east1' \
            --set-env-vars=GCP_CLUSTER_ID='workshop-knative' \
            --no-allow-unauthenticated \
            --region='asia-northeast1' \
            --service-account=$(get_sa_mail)
        ;;
    create-cronjob)
        export SERVICE_URL=$(get_run_url)
        gcloud beta scheduler jobs create http remove-workshop-knative-node-pool --schedule "0 1 * * *" \
            --time-zone=Asia/Taipei \
            --http-method=delete \
            --uri=$SERVICE_URL \
            --oidc-service-account-email=$(get_sa_mail) \
            --oidc-token-audience=$SERVICE_URL
        ;;
    create-node-pool)
        TOKEN=$(gcloud auth print-identity-token)
        URL=$(gcloud alpha run routes describe workshop-knative --platform=managed --region=asia-northeast1 --format=json | jq -r '.status.domain')
        curl -vv -X POST -H "Authorization: Bearer $TOKEN" $URL
        ;;
    *)
        echo "Invalid arguments $1"
        ;;
esac
