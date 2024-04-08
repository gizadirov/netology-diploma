local env = {
  name: std.extVar("qbec.io/env"),
  namespace: std.extVar("qbec.io/defaultNs"),
};
local p = import "../params.libsonnet";
local params = p.components.jenkins;

local tlsCert = importstr "../../../.secrets/netology.timurkin.ru.crt";
local tlsKey = importstr "../../../.secrets/netology.timurkin.ru.key";

[
  {
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
      name: params.name + "-secret",
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
        "nginx.ingress.kubernetes.io/ssl-passthrough": "true",
      },
      labels: { app: params.name },
      name: params.name + "-ingress",
    },
    spec: {
      ingressClassName: params.ingressClass,
      rules: [
        {
          host: params.domain,
          http: {
            paths: [
              {
                path: "/maintenance/jenkins",
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
          secretName: params.name + "-secret",
        },
      ],
    },
  },
]
