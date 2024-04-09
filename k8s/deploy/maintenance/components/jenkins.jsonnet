local env = {
  name: std.extVar("qbec.io/env"),
  namespace: "jenkins",
};
local p = import "../params.libsonnet";
local params = p.components.jenkins;

local tlsCert = importstr "../../../../.secrets/netology.timurkin.ru.crt";
local tlsKey = importstr "../../../../.secrets/netology.timurkin.ru.key";

[
  {
    apiVersion: "v1",
    kind: "PersistentVolume",
    metadata: {
      name: "local-vol",
    },
    spec: {
      capacity: {
        storage: "5Gi",
      },
      volumeMode: "Filesystem",
      accessModes: [
        "ReadWriteOnce",
      ],
      persistentVolumeReclaimPolicy: "Retain",
      "local": {
        path: "/data/jenkins/backup",
      },
      nodeAffinity: {
        required: {
          nodeSelectorTerms: [
            {
              matchExpressions: [
                {
                  key: "kubernetes.io/hostname",
                  operator: "In",
                  values: [
                    "k8s-node-0",
                  ],
                },
              ],
            },
          ],
        },
      },
    },
  },
  {
    apiVersion: "v1",
    kind: "Secret",
    metadata: {
      name: params.tlsSecretName,
      namespace: env.namespace,
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
      namespace: env.namespace,
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
          secretName: params.tlsSecretName,
        },
      ],
    },
  },
]
