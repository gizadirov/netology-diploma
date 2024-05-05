local env = {
  name: std.extVar("qbec.io/env"),
};

local expandHelmTemplate = std.native("expandHelmTemplate");


local p = import "../params.libsonnet";
local params = p.components.jenkins;

local tlsCert = importstr "../../../../.secrets/netology.timurkin.ru.crt";
local tlsKey = importstr "../../../../.secrets/netology.timurkin.ru.key";
local jenkins_conf = importstr "../../../../.secrets/jenkins.yaml";


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
      namespace: params.ns,
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
      namespace: params.ns,
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
  // {
  //   apiVersion: "v1",
  //   kind: "ConfigMap",
  //   metadata: {
  //     name: "jenkins-operator-user-configuration",
  //   },
  //   data: {
  //     "my-jenkins-configuration": jenkins_conf,
  //   },
  // },
  expandHelmTemplate(
    "../vendor/jenkins/jenkins-operator-0.8.0.tgz",
    params.values,
    {
      nameTemplate: params.name,
      namespace: "default",  //params.ns,
      thisFile: std.thisFile,
      verbose: true,
    }
  ),
  // {
  //   apiVersion: "jenkins.io/v1alpha2",
  //   kind: "Jenkins",
  //   metadata: {
  //     name: "apply-jenkins-conf",
  //     namespace: params.ns,
  //   },
  //   spec: {
  //     configurationAsCode: {
  //       configurations: [
  //         {
  //           name: "jenkins-operator-user-configuration",
  //         },
  //       ],
  //     },
  //   },
  // },
]
