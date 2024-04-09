#!/bin/bash

#helm repo add runatlantis https://runatlantis.github.io/helm-charts

#helm inspect values runatlantis/atlantis > values.yaml


helm upgrade atlantis runatlantis/atlantis -f values.yaml --namespace atlantis --create-namespace

