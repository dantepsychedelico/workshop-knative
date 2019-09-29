# Knative WorkShop

## Set up environment

### Create GKE Cluster

```
$ ./setup-gke-cluster.sh
```

- [Ref](https://knative.dev/docs/install/knative-with-gke/)
- [setup-gke-cluster.sh](setup-gke-cluster.sh)

### Get authentication credentials for the cluster

```
gcloud container clusters get-credentials workshop-knative
```

### Grant cluster-admin permissions to the current user

```
kubectl create clusterrolebinding cluster-admin-binding \
    --clusterrole=cluster-admin \
    --user=$(gcloud config get-value core/account)
```

### Install Knative

```
$ ./install-knative.sh
```

- [install-knative.sh](install-knative.sh)

## Deploying your first app

```
$ kubectl apply -f examples/helloworld-go/service.yaml
```

- [service.yaml](examples/helloworld-go/service.yaml)

### Interacting with your app

To find the IP address for your service
```
$ kubectl get svc istio-ingressgateway -n istio-system
NAME                   TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                                                                                                                                      AGE
istio-ingressgateway   LoadBalancer   10.0.13.242   35.221.191.47   15020:30799/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:32158/TCP,15030:30313/TCP,15031:32453/TCP,15032:31927/TCP,15443:30171/TCP   10h
```

To find the host URL for `helloworld-go`, enter:
```
$ kubectl get route helloworld-go
NAME            URL                                        READY     REASON
helloworld-go   http://helloworld-go.default.example.com   True
```

Send request to your app.
```
$ export IP_ADDRESS=$(kubectl get svc istio-ingressgateway -n istio-system -o 'jsonpath={.status.loadBalancer.ingress[0].ip}')
$ curl -H 'Host: helloworld-go.default.example.com' http://$IP_ADDRESS
```

## Assigning a static IP address for Knative on Kubernetes Engine

[Ref](https://knative.dev/docs/serving/gke-assigning-static-ip-address/)

### Reserve a static IP address

```
gcloud beta compute addresses create knative-workshop-istio-ingress-gw --region=asia-east1
gcloud beta compute addresses list
NAME                               ADDRESS/RANGE  TYPE      PURPOSE  NETWORK  REGION      SUBNET  STATUS
knative-workshop-istio-ingress-gw  35.221.191.47  EXTERNAL                    asia-east1          RESERVED
```

### Update the external IP of istio-ingressgateway service

```
$ export RESERVED_IP=$(gcloud beta compute addresses list --filter="name=knative-workshop-istio-ingress-gw" --format=json | jq -r '.[0].address')
$ kubectl patch svc istio-ingressgateway --namespace istio-system --patch '{"spec": { "loadBalancerIP": "'$RESERVED_IP'" }}'
service/istio-ingressgateway patched
```

### Verify the static IP address of istio-ingressgateway service

```
kubectl get services -n istio-system istio-ingressgateway
NAME                   TYPE           CLUSTER-IP    EXTERNAL-IP     PORT(S)                                                                                                                                      AGE
istio-ingressgateway   LoadBalancer   10.0.13.242   35.221.191.47   15020:30799/TCP,80:31380/TCP,443:31390/TCP,31400:31400/TCP,15029:32158/TCP,15030:30313/TCP,15031:32453/TCP,15032:31927/TCP,15443:30171/TCP   41h
```

## Setting up a custom domain

### Change domain `example.com` to your custom domain
Use `kubectl edit cm config-domain -n knative-serving` to remove `.metadata.annotations`

then apply `config-domain.yaml`

```
kubectl apply -f config-domain.yaml
```
[config-domain.yaml](config-domain.yaml)

### Update your DNS records

Create a Cloud DNS managed-zone

```
gcloud dns managed-zones create base1618-dev --dns-name=base1618-dev.com --description=''
```

Adding a recordset

```
gcloud dns record-sets transaction start --zone="base1618-dev"
gcloud dns record-sets transaction add 35.221.191.47 --zone="base1618-dev" \
--name="*.default.knative.base1618-dev.com." \
--type="A" \
--ttl=300
gcloud dns record-sets transaction execute --zone="base1618-dev"
```

### Verify deployment

[http://helloworld-go.default.knative.base1618-dev.com](http://helloworld-go.default.knative.base1618-dev.com)

## Accessing logs

### Kibana and Elasticsearch

```
$ kubectl proxy
```
Navigate to [Kibana UI](http://localhost:8001/api/v1/namespaces/knative-monitoring/services/kibana-logging/proxy/app/kibana)

### Accessing configuration and revision logs

To access the logs for a configuration:

- Find the configuration's name with the following command:

```
kubectl get configurations
```

- Replace `<CONFIGURATION_NAME>` and enter the following search query in Kibana:

```
kubernetes.labels.serving_knative_dev\/configuration: <CONFIGURATION_NAME>
```

To access logs for a revision:

- Find the revision's name with the following command:

```
kubectl get revisions
```

- Replace `<REVISION_NAME>` and enter the following search query in Kibana:

```
kubernetes.labels.serving_knative_dev\/revision: <REVISION_NAME>
```

## Canary Release

### Set env

```
$ export PROJECT_ID=$(gcloud config get-value project)
$ export REPO="gcr.io/$PROJECT_ID"
```

### Use Docker to build your application containe

```
cd examples/rest-api-go/
DOCKER_BUILDKIT=1 docker build -t $REPO/rest-api-go .
```

### Replace sample.yaml with environment variable

```
envsubst < sample-template.yaml > sample.yaml
```

### Deploy first app

```
kubectl apply -f sample.yaml
```

### Verify deployment

```
curl -H 'Host: stock-service-example.default.example.com' http://$IP_ADDRESS
```
