#!/usr/bin/env bash

kubectl apply -f ./ --recursive || true
sleep 10s