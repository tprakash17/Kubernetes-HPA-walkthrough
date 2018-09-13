#!/bin/bash

kubectl scale deployment node-deployment --replicas 6 -n nodejs

sleep 5

kubectl set image deployment/node-deployment nodeapp=tarun/nodejs-v1:v2 -n nodejs
