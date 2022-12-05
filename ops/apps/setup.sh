#!/usr/bin/env bash

kubectl delete namespace app-time-now
sleep 10

kubectl apply -f ./namespaces --recursive || true
sleep 10s
kubectl apply -f ./gateways --recursive || true