#!/usr/bin/env bash

# GKE AutoNEG
kubectl delete namespace autoneg-system
kubectl apply -f autoneg/install-manifests.yaml || true

# Istio Mesh
kubectl delete namespace istio-system 
kubectl apply -f istio/namespaces/namespace.yaml
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/plugins --recursive || true

# Ops
kubectl delete namespace ops-argocd
kubectl apply -f argocd/namespaces/namespace.yaml
kubectl apply -f argocd/install-manifests.yaml || true
kubectl apply -f virtualService.yaml  -n ops-argocd || true

# Apps
kubectl delete namespace app-time-now
kubectl delete namespace app-bank-of-anthos

kubectl apply -f apps/namespaces --recursive || true
kubectl apply -f apps/gateways --recursive || true