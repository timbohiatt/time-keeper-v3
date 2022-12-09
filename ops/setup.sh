#!/usr/bin/env bash

# Delete/Cleanup
#kubectl delete namespace autoneg-system
#kubectl delete namespace istio-system 
#kubectl delete namespace ops-argocd
#kubectl delete namespace app-time-now
kubectl delete namespace app-bank-of-anthos

# GKE AutoNEG
kubectl apply -f autoneg/install-manifests.yaml || true

# Istio Mesh
kubectl apply -f istio/namespaces/namespace.yaml
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/install-manifests.yaml || true
kubectl apply -f istio/plugins --recursive || true

# Ops
kubectl apply -f argocd/namespaces/namespace.yaml
kubectl apply -f argocd/install-manifests.yaml || true
kubectl apply -f argocd/virtualService.yaml  -n ops-argocd || true

# Apps Cluster
kubectl apply -f apps/namespaces --recursive || true
kubectl apply -f apps/gateways --recursive || true

# Apps Deploymentd
kubectl apply -f ../apps/ --recursive || true