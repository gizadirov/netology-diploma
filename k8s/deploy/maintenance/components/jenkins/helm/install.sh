#!/bin/bash

helm repo add jenkins https://raw.githubusercontent.com/jenkinsci/kubernetes-operator/master/chart

helm repo update

helm upgrade --install jenkins jenkins/jenkins-operator \
    -f values.yaml \
    --namespace jenkins --create-namespace

#kubectl -n jenkins set env deployment/jenkins-jenkins-operator JENKINS_OPTS="--prefix=/maintenance/jenkins"

#kubectl apply -f pv.yaml
