#!/usr/bin/env bash

kubectl delete namespace istio-system 
kubectl delete namespace ops-argocd 
sleep 30s
kubectl apply -f istio/namespaces/namespace.yaml
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/plugins --recursive || true
sleep 10s
kubectl apply -f argocd/ --recursive || true