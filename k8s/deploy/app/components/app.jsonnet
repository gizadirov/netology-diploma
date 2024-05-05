local env = {
  name: std.extVar("qbec.io/env"),
  namespace: std.extVar("qbec.io/defaultNs"),
};
local p = import '../params.libsonnet';
local params = p.components.app;

local imageTag = std.extVar('imageTag');

[
  {
    apiVersion: "apps/v1",
    kind: "Deployment",
    metadata: {
      labels: { app: params.name },
      name: params.name,
    },
    spec: {
      strategy: { type: "RollingUpdate", maxSurge: "50%", maxUnavailable: "50%" },
      replicas: params.replicas,
      selector: {
        matchLabels: {
          app: params.name,
        },
      },
      template: {
        metadata: {
          labels: { app: params.name },
        },
        spec: {
          containers: [
            {
              name: params.name,
              image: params.image + ":" + imageTag,
              ports: [
                {
                  containerPort: params.containerPort,
                },
              ],
            },
          ],
          nodeSelector: params.nodeSelector,
          tolerations: params.tolerations,
          imagePullSecrets: [{ name: params.crSecretName }],
        },
      },
    },
  },
]
