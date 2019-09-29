#!/bin/bash

gcloud beta container clusters create workshop-knative \
    --addons=HorizontalPodAutoscaling,HttpLoadBalancing,Istio \
    --machine-type=n1-standard-4 \
    --cluster-version=latest --zone=asia-east1-a \
    --enable-stackdriver-kubernetes --enable-ip-alias \
    --enable-autoscaling --min-nodes=1 --max-nodes=5 \
    --enable-autorepair \
    --preemptible \
    --num-nodes=1 \
    --scopes cloud-platform
