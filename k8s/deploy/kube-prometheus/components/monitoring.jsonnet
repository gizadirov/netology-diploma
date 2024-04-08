local env = {
  name: std.extVar("qbec.io/env"),
  namespace: std.extVar("qbec.io/defaultNs"),
};
local p = import "../params.libsonnet";
local params = p.components.monitoring;

local tlsCert = importstr "../../../.secrets/netology.timurkin.ru.crt";
local tlsKey = importstr "../../../.secrets/netology.timurkin.ru.key";

[
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
        "nginx.ingress.kubernetes.io/rewrite-target": "/$2",
        #"nginx.ingress.kubernetes.io/ssl-passthrough": "true",
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
          secretName: params.name + "-secret",
        },
      ],
    },
  },
]
