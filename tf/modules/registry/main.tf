resource "yandex_container_registry" "registry" {
  name = var.name
}

resource "yandex_container_repository" "repo" {
  name = "${yandex_container_registry.registry.id}/${var.repo_name}"
}

//Сервис аккаунт для доступа к registry
resource "yandex_iam_service_account" "sa" {
  name = "registry"
}


resource "yandex_container_repository_iam_binding" "puller" {
  repository_id = yandex_container_repository.repo.id
  role          = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}

resource "yandex_container_repository_iam_binding" "pusher" {
  repository_id = yandex_container_repository.repo.id
  role          = "container-registry.images.pusher"
  members = [
    "serviceAccount:${yandex_iam_service_account.sa.id}",
  ]
}

