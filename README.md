
# Introduction
This is sample nodejs app which exposes 2 end-points:

1. / - Returns Hello
2. /version - increments and returns count everytime this api is hit/refreshed

# Instructions

1. clone repo
   ```
   git clone https://github.com/tprakash17/nodejs-sample-app-kubernetes.git
   cd nodejs-sample-app-kubernetes/node_app
   ```
2. Build docker image
   ``` 
   sudo docker build -t nodejs-v1 .
   ```

3. Verify app locally by running container 
   ```
   docker run -d --name <SOMENAME> -p 8080:3000 nodejs-v1:latest
   ```
  Note: nodejs-v1:latest image has been pushed to dockerhub as well and its publically available. (docker pull tarun/nodejs-v1)

4 Access in your local browser
  
  http://localhost:8080
  
  http://localhost:8080/version

# Deploy app in kubernetes

## create deployment

```
root@Blr-Tarunp:~/nodejs-sample-app-kubernetes/kubernetes/artifacts# kubectl get all,ing -n nodejs
NAME                                 READY     STATUS        RESTARTS   AGE
po/node-deployment-97f45c487-jphkt   1/1       Running       0          1h
po/node-deployment-97f45c487-rpch4   1/1       Running       0          1h

NAME              CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
svc/nodeapp-svc   10.43.80.18   <nodes>       80:31283/TCP   1h

NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/node-deployment   2         2         2            2           1h

NAME                           DESIRED   CURRENT   READY     AGE
rs/node-deployment-97f45c487   2         2         2         1h
```

## Describe svc 

```
root@Blr-Tarunp:~/nodejs-sample-app-kubernetes/kubernetes/artifacts# kubectl describe svc/nodeapp-svc -n nodejs
Name:                   nodeapp-svc
Namespace:              nodejs
Labels:                 <none>
Annotations:            <none>
Selector:               app=nodeapp,color=blue,env=dev
Type:                   NodePort
IP:                     10.43.80.18
Port:                   http    80/TCP
NodePort:               http    31283/TCP
Endpoints:              10.42.142.245:3000,10.42.252.214:3000
Session Affinity:       None
Events:                 <none>
```

## Horizontal scaling  

```
$ kubectl autoscale deployment node-deployment --cpu-percent=40 --min=2 --max=10 -n nodejs
```

## Scaler status 

```
root@Blr-Tarunp:~/nodejs-sample-app-kubernetes/kubernetes/artifacts# kubectl get all,ing -n nodejs
NAME                                  READY     STATUS    RESTARTS   AGE
po/node-deployment-548dd87cc6-8hdsn   1/1       Running   0          2m
po/node-deployment-548dd87cc6-ct724   1/1       Running   0          2m

NAME              CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
svc/nodeapp-svc   10.43.80.18   <nodes>       80:31283/TCP   1h

NAME                  REFERENCE                    TARGETS    MINPODS   MAXPODS   REPLICAS   AGE
hpa/node-deployment   Deployment/node-deployment   0% / 30%   2         10        2          36s

NAME                     DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
deploy/node-deployment   2         2         2            2           1h

NAME                            DESIRED   CURRENT   READY     AGE
rs/node-deployment-548dd87cc6   2         2         2         2m
rs/node-deployment-97f45c487    0         0         0         1h
```

## Increase load
```
$ kubectl run -i --tty load-generator --image=busybox /bin/sh -n nodejs

Hit enter for command prompt

# while true; do wget -q -O- http://10.43.80.18; done

Note: Change the clusterIP it may be different be when you deploy.

root@Blr-Tarunp:~/nodejs-sample-app-kubernetes/kubernetes/artifacts# watch kubectl get hpa -n nodejs
Every 2.0s: kubectl get hpa -n nodejs                                                                                                           Thu Sep 13 18:50:29 2018

NAME              REFERENCE                    TARGETS     MINPODS   MAXPODS   REPLICAS   AGE
node-deployment   Deployment/node-deployment   34% / 30%   2         10        4          14m
```

Now you can deployment has scaled to 4 copies automatically as load increased more than 30 %

```
root@Blr-Tarunp:~/nodejs-sample-app-kubernetes/kubernetes/artifacts# kubectl get deploy -n nodejs
NAME              DESIRED   CURRENT   UP-TO-DATE   AVAILABLE   AGE
load-generator    1         1         1            1           12m
node-deployment   4         4         4            4           1h
```

Now, delete the load generator.

```
root@Blr-Tarunp:~/nodejs-sample-app-kubernetes/kubernetes/artifacts# kubectl delete deploy/load-generator -n nodejs
deployment "load-generator" deleted
```

verify that load has started coming down

```
root@Blr-Tarunp:~/nodejs-sample-app-kubernetes/kubernetes/artifacts# watch kubectl get hpa -n nodejs
Every 2.0s: kubectl get hpa -n nodejs                                                                                                           Thu Sep 13 18:55:35 2018

NAME              REFERENCE                    TARGETS     MINPODS   MAXPODS   REPLICAS   AGE
node-deployment   Deployment/node-deployment   11% / 30%   2         10        5          19m
```


## Rolling update

Go to nodejs-sample-app-kubernetes/kubernetes DIR run the script to do rolling update.

```
root@Blr-Tarunp:~/nodejs-sample-app-kubernetes/kubernetes# ./rolling-update.sh
deployment "node-deployment" scaled
deployment "node-deployment" image updated
```


## Blue green deployment 

1. Deploy new version of your app with updated label
2. Change selector at svc level to match new label

```
root@Blr-Tarunp:~/nodejs-sample-app-kubernetes/kubernetes# ./blue-green-update.sh
deployment "node-green-deployment" created
Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply
service "nodeapp-svc" configured
```
