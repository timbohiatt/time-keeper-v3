#!/usr/bin/env bash

kubectl apply -f istio/namespaces/namespace.yaml
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/plugins --recursive || true

kubectl get namespaces 
kubectl get pods
