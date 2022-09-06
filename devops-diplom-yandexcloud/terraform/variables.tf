# ID облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_cloud_id" {
  default = "b1g72svo67706rdk1ego"
}

# Folder облака
# https://console.cloud.yandex.ru/cloud?section=overview
variable "yandex_folder_id" {
  default = "b1go323tfuedmc7ac54e"
}

variable "token" {
  default = "..."
}


# bucket
# 
variable "yandex_buket" {
  default = "s3-tundracode"
}

# Заменить на access_key
# 
variable "yandex_s3_acc_key" {
  default = "..."
}

# Заменить на secret_key
# 
variable "yandex_s3_sec_key" {
  default = "..."
}

# Наш домен
variable "my_domain" {
  default = "tundracode.ru"
}

# По умолчанию используем реальные сертификаты Let's Encrypt
variable "my_le_staging" {
  default = "false"
}

# Внутренние переменные.

# ID образа Ubuntu 20.04 LTS
# 
variable "ubuntu-latest" {
  default = "fd87tirk5i8vitv9uuo1"
}

# ID Образа Ubuntu 18.04 для Nat
# 
variable "ubuntu-nat" {
  default = "fd84mnpg35f7s7b0f5lg"
}

#
# Токен для работы Gitlab c runner
variable "my_gitlab_runner" {
  default = "o9PZATGl+oOKkyN+06jRq0usrREGzHpV7cg26xJcYBk="
}

#
# Внутренний пароль для репликации между базами MySQL
variable "my_replicator_psw" {
  default = "P@sswW0rd!R"
}

# Пароли для доступа к графическим интерфейсам.

#
# Пароль для доступа к Grafana от пользователя `admin`
variable "my_grafana_psw" {
  default = "P@ssW0rd!G"
}

#
# Пароль для доступа к Gitlab от пользователя `root`
variable "my_gitlab_psw" {
  default = "Gitl@bPa$$word"
}


