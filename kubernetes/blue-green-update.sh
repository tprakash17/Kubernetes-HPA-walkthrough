#!/bin/bash

kubectl apply -f ./artifacts/nodejs-green-deploy.yaml
kubectl apply -f ./artifacts/nodejs-svc-green-nodeport.yaml 

