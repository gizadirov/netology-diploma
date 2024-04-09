{
  local common = {
    tlsSecretName : "netology-timurkin-ru-secret",
    ingressClass : "nginx",
    domain : "netology.timurkin.ru",
  },
  components: {
    monitoring: {
      name: "grafana",
      servicePort: 3000,
      serviceName: "grafana",
    } + common,
    atlantis: {
      name: "atlantis",
      servicePort: 3041,
      serviceName: "atlantis",
    } + common,
    jenkins: {
      name: "jenkins",
      servicePort: 8080,
      serviceName: "jenkins-operator-http-jenkins",
    } + common,
    pv:{}
  },
}
