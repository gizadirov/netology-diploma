local env = {
  name: std.extVar("qbec.io/env"),
};
local p = import "../params.libsonnet";

[
  {
    apiVersion: "v1",
    kind: "PersistentVolume",
    metadata: {
      name: "pv-0-0",
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
        path: "/data/pv-0",
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
    kind: "PersistentVolume",
    metadata: {
      name: "pv-0-1",
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
        path: "/data/pv-1",
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
    kind: "PersistentVolume",
    metadata: {
      name: "pv-0-2",
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
        path: "/data/pv-2",
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
    kind: "PersistentVolume",
    metadata: {
      name: "pv-1-0",
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
        path: "/data/pv-0",
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
                    "k8s-node-1",
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
    kind: "PersistentVolume",
    metadata: {
      name: "pv-1-1",
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
        path: "/data/pv-1",
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
                    "k8s-node-1",
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
    kind: "PersistentVolume",
    metadata: {
      name: "pv-1-2",
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
        path: "/data/pv-2",
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
                    "k8s-node-1",
                  ],
                },
              ],
            },
          ],
        },
      },
    },
  },
]
