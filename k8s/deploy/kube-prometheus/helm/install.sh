#!/bin/bash

#git submodule add --depth=1 https://github.com/prometheus-operator/kube-prometheus kube-prometheus

kubectl delete --ignore-not-found=true -f kube-prometheus/manifests/ -f kube-prometheus/manifests/setup

kubectl apply --server-side -f kube-prometheus/manifests/setup
kubectl wait \
	--for condition=Established \
	--all CustomResourceDefinition \
	--namespace=monitoring

kubectl apply -f kube-prometheus/manifests/

kubectl -n monitoring set env deployment/grafana GF_SERVER_DOMAIN=netology.timurkin.ru GF_SERVER_ROOT_URL=https://netology.timurkin.ru/maintenance/grafana
