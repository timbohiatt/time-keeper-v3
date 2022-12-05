#!/usr/bin/env bash

kubectl apply -f apps/namespaces --recursive || true
sleep 10s
kubectl apply -f apps/gateways --recursive || true