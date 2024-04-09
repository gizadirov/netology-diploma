local env = {
  name: std.extVar("qbec.io/env"),
  namespace: "monitoring",
};
local p = import "../params.libsonnet";
local params = p.components.monitoring;

local tlsCert = importstr "../../../.secrets/netology.timurkin.ru.crt";
local tlsKey = importstr "../../../.secrets/netology.timurkin.ru.key";

local tlsCert = importstr "../../../../.secrets/netology.timurkin.ru.crt";
local tlsKey = importstr "../../../../.secrets/netology.timurkin.ru.key";

[
  {
    apiVersion: "v1",
    kind: "PersistentVolumeClaim",
    metadata: {
      name: "grafana-pvc",
      namespace: env.namespace,
    },
    spec: {
      accessModes: [
        "ReadWriteOnce",
      ],
      resources: {
        requests: {
          storage: "5Gi",
        },
      },
      selector: {
        matchLabels: {
          "app.kubernetes.io/component": "grafana",
        },
      },
    },
  },
  {
    apiVersion: "networking.k8s.io/v1",
    kind: "NetworkPolicy",
    metadata: {
      labels: {
        "app.kubernetes.io/component": "grafana",
        "app.kubernetes.io/name": "grafana",
        "app.kubernetes.io/part-of": "kube-prometheus",
        "app.kubernetes.io/version": "9.0.1",
      },
      name: params.name,
      namespace: env.namespace,
    },
    spec: {
      egress: [
        {
        },
      ],
      ingress: [
        {
          ports: [
            {
              port: params.servicePort,
              protocol: "TCP",
            },
          ],
        },
      ],
      podSelector: {
        matchLabels: {
          "app.kubernetes.io/component": "grafana",
          "app.kubernetes.io/name": "grafana",
          "app.kubernetes.io/part-of": "kube-prometheus",
        },
      },
      policyTypes: [
        "Egress",
        "Ingress",
      ],
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
        "nginx.ingress.kubernetes.io/rewrite-target": "/$2",
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
                path: "/maintenance/grafana(/|$)(.*)",
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
