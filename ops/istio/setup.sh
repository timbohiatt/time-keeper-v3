#!/usr/bin/env bash

kubectl delete namespace istio-system 
kubectl apply -f istio/namespaces/namespace.yaml
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/plugins --recursive || true