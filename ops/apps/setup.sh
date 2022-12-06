#!/usr/bin/env bash

kubectl delete namespace app-time-now
kubectl delete namespace app-bank-of-anthos

kubectl apply -f ./namespaces --recursive || true
kubectl apply -f ./gateways --recursive || true