local env = {
  name: std.extVar("qbec.io/env"),
  namespace: std.extVar("qbec.io/defaultNs"),
};
local p = import '../params.libsonnet';
local params = p.components.app;

//local imageTag = std.extVar('imageTag');

local dockerConfig = importstr "../../../../.secrets/dockerconfig.json";
local tlsCert = importstr "../../../../.secrets/netology.timurkin.ru.crt";
local tlsKey = importstr "../../../../.secrets/netology.timurkin.ru.key";

[
  {
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
      name: params.crSecretName,
    },
    data: {
      ".dockerconfigjson": std.base64(dockerConfig),
          },
    type: "kubernetes.io/dockerconfigjson",
  },
  {
    apiVersion: "v1",
    kind: "Service",
    metadata: {
      labels: { app: params.name },
      name: params.name,
    },
    spec: {
      selector: {
        app: params.name,
      },
      ports: [
        {
          port: params.servicePort,
          targetPort: params.containerPort,
        },
      ],
    },
  },
  {
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
      name: params.tlsName,
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
        "nginx.ingress.kubernetes.io/rewrite-target": "/",
      },
      labels: { app: params.name },
      name: params.name,
    },
    spec: {
      ingressClassName: params.ingressClass,
      rules: [
        {
          host: params.domain,
          http: {
            paths: [
              {
                path: "/",
                pathType: "Prefix",
                backend: {
                  service: {
                    name: params.name,
                    port: {
                      number: params.servicePort,
                    },
                  },
                },
              },
            ]
          },
        },
      ],
      tls: [
        {
          hosts: [params.domain],
          secretName: params.tlsName,
        },
      ],
    },
  },
]
