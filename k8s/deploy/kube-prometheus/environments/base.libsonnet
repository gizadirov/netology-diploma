{
  components: {
    monitoring: {
      name: "grafana",
      ingressClass: "nginx",
      domain: "netology.timurkin.ru",
      servicePort: 3000,
      serviceName: "grafana",
    },
  },
}
