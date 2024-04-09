{
  components: {
    jenkins: {
      name: "jenkins",
      ingressClass: "nginx",
      domain: "netology.timurkin.ru",
      servicePort: 8080,
      serviceName: "jenkins-operator-http-jenkins",
    },
  },
}
