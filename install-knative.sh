#!/bin/bash

# with the -l knative.dev/crd-install=true flag. This prevents race conditions during the install
kubectl apply -l knative.dev/crd-install=true \
   -f https://github.com/knative/serving/releases/download/v0.9.0/serving.yaml \
   -f https://github.com/knative/eventing/releases/download/v0.9.0/release.yaml \
   -f https://github.com/knative/serving/releases/download/v0.9.0/monitoring.yaml

kubectl apply -f https://github.com/knative/serving/releases/download/v0.9.0/serving.yaml \
    -f https://github.com/knative/eventing/releases/download/v0.9.0/release.yaml \
    -f https://github.com/knative/serving/releases/download/v0.9.0/monitoring.yaml
