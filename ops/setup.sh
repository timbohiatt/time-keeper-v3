#!/usr/bin/env bash

kubectl delete namespace istio-system 
sleep 10s
kubectl apply -f istio/namespaces/namespace.yaml
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/plugins --recursive || true

sleep 10s
kubectl get namespaces 

sleep 10s
kubectl get pods
