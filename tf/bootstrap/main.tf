//Сервис аккаунт терраформа
resource "yandex_iam_service_account" "sa" {
  name = "terraform"
}

// Назначение роли сервисному аккаунту
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  depends_on = [yandex_iam_service_account.sa]
  folder_id  = var.folder_id
  role       = "editor"
  member     = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

//Назначение прав admin для операций с registry
resource "yandex_resourcemanager_folder_iam_member" "sa-registry-admin" {
  depends_on = [yandex_iam_service_account.sa]

  folder_id = var.folder_id
  role      = "container-registry.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Создание статического ключа доступа
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  depends_on         = [yandex_resourcemanager_folder_iam_member.sa-editor]
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for terraform sa"
}

// Создание бакета с использованием ключа
resource "yandex_storage_bucket" "terraform_backend_bucket" {
  depends_on    = [yandex_iam_service_account_static_access_key.sa-static-key]
  access_key    = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key    = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket        = "timurkinx-netology-terraform"
  force_destroy = true
}

// Конфигурация бекэнда основного терраформа
resource "null_resource" "terraform-backend" {
  depends_on = [yandex_storage_bucket.terraform_backend_bucket]

  provisioner "local-exec" {
    when        = create
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}/../tf"
    command     = <<-EOT
         if [ ! -d ".terraform" ]; then terraform init -backend-config="access_key=${yandex_iam_service_account_static_access_key.sa-static-key.access_key}" -backend-config="secret_key=${yandex_iam_service_account_static_access_key.sa-static-key.secret_key}"; fi
      EOT
  }
}

//Создание ключа для сервис аккаунта
resource "yandex_iam_service_account_key" "sa-key" {
  depends_on         = [null_resource.terraform-backend]
  service_account_id = yandex_iam_service_account.sa.id
}

locals {
  key_object = {
    "id"                 = yandex_iam_service_account_key.sa-key.id,
    "service_account_id" = yandex_iam_service_account_key.sa-key.service_account_id,
    "created_at"         = yandex_iam_service_account_key.sa-key.created_at,
    "key_algorithm"      = yandex_iam_service_account_key.sa-key.key_algorithm,
    "public_key"         = yandex_iam_service_account_key.sa-key.public_key,
    "private_key"        = yandex_iam_service_account_key.sa-key.private_key
  }
}

// Конфигурация iam ключа сервис аккаунта
resource "local_file" "key_json" {
  depends_on = [yandex_iam_service_account_key.sa-key]

  filename = "${path.module}/../.secrets/key.json"
  content  = jsonencode(local.key_object)
}

// Отчистка
resource "null_resource" "clean" {
  provisioner "local-exec" {
    when        = destroy
    interpreter = ["/bin/bash", "-c"]
    working_dir = "${path.module}/../tf"
    command     = "rm -rf .terraform || rm .terraform.lock.hcl || rm key.json"
  }
}

