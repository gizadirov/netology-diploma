local expandHelmTemplate = std.native("expandHelmTemplate");
local env = {
  name: std.extVar("qbec.io/env"),
  namespace: "atlantis",
};
local p = import "../params.libsonnet";
local params = p.components.atlantis;

local tlsCert = importstr "../../../../.secrets/netology.timurkin.ru.crt";
local tlsKey = importstr "../../../../.secrets/netology.timurkin.ru.key";

[
  {
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
      name: params.ns,
    },
  },
  {
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
      name: params.tlsSecretName,
    },
    data: {
      "tls.crt": std.base64(tlsCert),
      "tls.key": std.base64(tlsKey),
    },
    type: "kubernetes.io/tls",
  },
  {
    apiVersion: "networking.k8s.io/v1",
    kind: "Ingress",
    metadata: {
      annotations: {
        "kubernetes.io/ingress.class": params.ingressClass,
      },
      labels: { app: params.name },
      name: params.name + "-ingress",
      namespace: env.namespace,
    },
    spec: {
      ingressClassName: params.ingressClass,
      //"nginx.ingress.kubernetes.io/rewrite-target": "/$2",
      "nginx.ingress.kubernetes.io/rewrite-target": "/",
      rules: [
        {
          host: params.domain,
          http: {
            paths: [
              {
                //path: "/maintenance/atlantis(/|$)(.*)",
                path: "/maintenance/atlantis",
                pathType: "Prefix",
                backend: {
                  service: {
                    name: params.serviceName,
                    port: {
                      number: params.servicePort,
                    },
                  },
                },
              },
            ],
          },
        },
      ],
      tls: [
        {
          hosts: [params.domain],
          secretName: params.tlsSecretName,
        },
      ],
    },
  },
  expandHelmTemplate(
    "../vendor/atlantis/atlantis-4.25.0.tgz",
    params.values,
    {
      nameTemplate: params.name,
      //namespace: params.ns,
      thisFile: std.thisFile,
      verbose: true,
      //execute: ["NAMESPACE=atlantis"]
    }
  ),
]
