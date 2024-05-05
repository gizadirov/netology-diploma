local p = import "../params.libsonnet";
local params = p.components.ingress_nginx;

local expandHelmTemplate = std.native("expandHelmTemplate");

[
  {
    apiVersion: "v1",
    kind: "Namespace",
    metadata: {
      name: params.ns,
    },
  },
  expandHelmTemplate(
    "../vendor/ingress-nginx/ingress-nginx-4.10.0.tgz",
    params.values,
    {
      nameTemplate: params.name,
      namespace: params.ns,
      thisFile: std.thisFile,
      verbose: true,
    }
  ),
]
