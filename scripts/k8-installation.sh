#!/bin/bash
#
#  Copyright (c) 2020 General Electric Company. All rights reserved.
#
#  The copyright to the computer software herein is the property of
#  General Electric Company. The software may be used and/or copied only
#  with the written permission of General Electric Company or in accordance
#  with the terms and conditions stipulated in the agreement/contract
#  under which the software has been supplied.
#
#  Author: apolo.yasuda@ge.com; apolo.yasuda.ge@gmail.com
#

{
    agent -ver
} || {
    printf "\n\nmissing agent. begin agent installation\n"
    source <(wget -O - https://raw.githubusercontent.com/EC-Release/sdk/disty/scripts/agt/v1.2beta.linux64.txt) -ver
}

kubectl get pods -A

printf "\n\n*** k8 installation\n\n"
kubectl config view

APISERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name==\"minikube\")].cluster.server}")

kubectl apply -f - <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: default-token
  annotations:
    kubernetes.io/service-account.name: default
type: kubernetes.io/service-account-token
EOF

while ! kubectl describe secret default-token | grep -E '^token' >/dev/null; do
  echo "waiting for token..." >&2
  sleep 1
done

# get the token value
TOKEN=$(kubectl get secret default-token -o jsonpath='{.data.token}' | base64 --decode)
printf "\n\n*** TOKEN: %s. APISERVER: %s\n\n" "$TOKEN" "$APISERVER"

# test endpoint
curl -X GET $APISERVER/api --header "Authorization: Bearer $TOKEN" --insecure
