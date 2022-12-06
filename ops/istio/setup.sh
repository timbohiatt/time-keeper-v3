#!/usr/bin/env bash

kubectl delete namespace istio-system 
kubectl apply -f namespaces/namespace.yaml
kubectl apply -f install-manifests.yaml || true
kubectl apply -f install-manifests.yaml || true
kubectl apply -f plugins --recursive || true