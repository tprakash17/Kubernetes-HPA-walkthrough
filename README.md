
# Introduction
This is sample nodejs app which exposes 2 end-points:

1. / - Returns Hello
2. /version - increments and returns count everytime this api is hit/refreshed

# Instructions

1. clone repo
   ```
   git clone git@github.com:tprakash17/nodejs-sample-app-kubernetes.git
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
