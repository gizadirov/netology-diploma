{
  components: {
    app: {
      name: "netology-diploma-app",
      image: "cr.yandex/crp0c81tkbq1dub8dc8c/app",
      replicas: 2,
      containerPort: 80,
      servicePort: 80,
      nodeSelector: {},
      tolerations: [],
      ingressClass: "nginx",
      crSecretName: "yandex-registry-secret",
      domain: "netology.timurkin.ru",
      tlsName: "netology-timurkin-ru",
    },
  },
}
