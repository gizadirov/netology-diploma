local jenkinsConfig = importstr "../../../../.secrets/jenkins.yaml";
{
  local common = {
    tlsSecretName: "netology-timurkin-ru-secret",
    ingressClass: "nginx",
    domain: "netology.timurkin.ru",
  },
  components: {
    ingress_nginx: {
      name: "ingress-nginx",
      ns: "ingress-nginx",
      values: {
        controller: {
          service: {
            type: "NodePort",
            nodePorts: {
              http: 30080,
              https: 30443,
            },
          },
          config: {
            pid: "/tmp/nginx/ingress_nginx.pid",
            "compute-full-forwarded-for": true,
            "use-forwarded-headers": true,
          },
        },
      },
    },
    monitoring: {
      name: "grafana",
      ns: "monitoring",
      servicePort: 3000,
      serviceName: "grafana",
    } + common,
    atlantis: {
      name: "atlantis",
      ns: "atlantis",
      servicePort: 3041,
      serviceName: "atlantis",
      values: {
        atlantisUrl: "https://netology.timurkin.ru/maintenance/atlantis",
      },
    } + common,
    jenkins: {
      name: "jenkins",
      ns: "jenkins",
      servicePort: 8080,
      serviceName: "jenkins-operator-http-jenkins",
      values: {
        jenkins: {
          namespace: "jenkins",
          replicaCount: 1,
          disableCSRFProtection: true,
          basePlugins: [
            {
              name: "configuration-as-code",
              version: "1775.v810dc950b_514",
            },
            {
              name: "kubernetes",
              version: "4054.v2da_8e2794884",
            },
            {
              name: "workflow-job",
              version: "1385.vb_58b_86ea_fff1",
            },
            {
              name: "workflow-aggregator",
              version: "596.v8c21c963d92d",
            },
            {
              name: "git",
              version: "5.2.1",
            },
            {
              name: "job-dsl",
              version: "1.87",
            },
            {
              name: "kubernetes-credentials-provider",
              version: "1.262.v2670ef7ea_0c5",
            },
          ],
          plugins: [
            {
              name: "docker-plugin",
              version: "1.5",
            },
            {
              name: "docker-workflow",
              version: "572.v950f58993843",
            },
            {
              name: "github",
              version: "1.37.3.1",
            },
            {
              name: "generic-webhook-trigger",
              version: "2.0.1",
            },
          ],
          // seedJobs: [
          //   {
          //     id: "jenkins-operator",
          //     targets: "cicd/jobs/*.jenkins",
          //     description: "Jenkins Operator repository",
          //     repositoryBranch: "main",
          //     repositoryUrl: "https://github.com/gizadirov/netology-diploma.git",
          //   },
          // ],
          env: [
            {
              name: "JENKINS_OPTS",
              value: "--prefix=/maintenance/jenkins",
            },
            {
              name: "BACKUP_COUNT",
              value: "1",
            },
          ],
          backup: {
            pvc: {
              size: "5Gi",
              className: "local-storage",
            },
          },
          configuration: {
            configurationAsCode: [
                {
                  configMapName: 'jenkins-config',
                  content: 
                  {
                    fullConfig: jenkinsConfig
                  }
                }
                
            ],
            // secretData: {
            //   user: std.base64('admin'),
            //   password: std.base64('netology'),
            // }
          },
        },
        operator: {
          replicaCount: 1,

          affinity: {
            nodeAffinity: {
              requiredDuringSchedulingIgnoredDuringExecution: {
                nodeSelectorTerms: [
                  {
                    matchExpressions: [
                      {
                        key: "kubernetes.io/hostname",
                        operator: "In",
                        values: ['k8s-node-0'],
                      },
                    ],
                  },
                ],
              },
            },
          },
        },
      },
    } + common,
    pv: {},
  },
}
