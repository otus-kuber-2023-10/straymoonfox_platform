#!/bin/bash

export POD_NAME=$(kubectl get pods --namespace monitoring -l "app.kubernetes.io/component=exporter,app.kubernetes.io/name=node-exporter" -o jsonpath="{.items[1].metadata.name}")

kubectl --namespace monitoring port-forward $POD_NAME 9100:9100 --address 0.0.0.0
