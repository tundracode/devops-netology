# Дипломный практикум в YandexCloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
      * [Регистрация доменного имени](#регистрация-доменного-имени)
      * [Создание инфраструктуры](#создание-инфраструктуры)
          * [Установка Nginx и LetsEncrypt](#установка-nginx)
          * [Установка кластера MySQL](#установка-mysql)
          * [Установка WordPress](#установка-wordpress)
          * [Установка Gitlab CE, Gitlab Runner и настройка CI/CD](#установка-gitlab)
          * [Установка Prometheus, Alert Manager, Node Exporter и Grafana](#установка-prometheus)

---
## Цели:

1. Зарегистрировать доменное имя (любое на ваш выбор в любой доменной зоне).
2. Подготовить инфраструктуру с помощью Terraform на базе облачного провайдера YandexCloud.
3. Настроить внешний Reverse Proxy на основе Nginx и LetsEncrypt.
4. Настроить кластер MySQL.
5. Установить WordPress.
6. Развернуть Gitlab CE и Gitlab Runner.
7. Настроить CI/CD для автоматического развёртывания приложения.
8. Настроить мониторинг инфраструктуры с помощью стека: Prometheus, Alert Manager и Grafana.

---
## Этапы выполнения:

### Регистрация доменного имени

Зарегистрирован домен `tundracode.ru` у регистратора [reg.ru](https://reg.ru). Домен делегирован под управление ns1.yandexcloud.net и ns2.yandexcloud.net.

![Reg.ru domain](img/Screenshot%202022-09-06%20at%2019.39.13.png)


### Создание инфраструктуры

В начале инициализируем бэкенд S3
```bash
cd s3_init/ || return
terraform init && terraform plan && terraform apply --auto-approve
```
После этого в каталоге `terraform` все переменные в файле variables.tf должны быть заполнены соответствующими значениям.


```bash
cd ../terraform/ || return
terraform init && terraform plan && terraform apply --auto-approve
```
После окончания выполнения в облаке имеем ресурсы:

![](img/Screenshot%202022-09-06%20at%2019.59.17.png)

![](img/Screenshot%202022-09-06%20at%2011.49.58.png)

Далее автоматически запускается настройка хостов с помощью ansible.

---
### Установка Nginx и LetsEncrypt

nginx - роль Ansible для установки Nginx и LetsEncrypt.



В нашей доменной зоне настроены все A-записи на внешний адрес этого сервера:
    - `https://www.tundracode.ru` (WordPress)
    - `https://gitlab.tundracode.ru` (Gitlab)
    - `https://grafana.tundracode.ru` (Grafana)
    - `https://prometheus.tundracode.ru` (Prometheus)
    - `https://alertmanager.tundracode.ru` (Alert Manager)


![](img/Screenshot%202022-09-06%20at%2011.51.04.png)

Автоматически сгенерированный сайт:

![](img/Screenshot%202022-09-06%20at%2011.48.17.png)

___
### Установка кластера MySQL

Разработана Ansible роль для установки отказоустойчивого кластера баз данных MySQL. В кластере автоматически создаётся база данных c именем `wordpress`. Автоматически создаётся пользователь `wordpress` с полными правами на базу `wordpress` и паролем `wordpress`.


![](img/Screenshot%202022-09-06%20at%2020.31.01.png)

___
### Установка WordPress

WordPress развернут и подключен к базе wordpress кластера MySQL


![](img/Screenshot%202022-09-06%20at%2011.48.17.png)

---
### Установка Gitlab CE и Gitlab Runner

Интерфейс Gitlab доступен по https. В вашей доменной зоне настроена A-запись на внешний адрес reverse proxy `https://gitlab.tundracode.ru` (Gitlab)

![](img/Screenshot%202022-09-06%20at%2014.33.23.png)

Пример фалйла `.gitlab-ci.yml`

```yaml
stages:
  - deploy

deploy-job:
  stage: deploy
  tags:
    - v1.0.0
  script:
    - if [ "$CI_COMMIT_TAG" = "" ] ; then echo "Need add tag!";
      else 
        ssh -o StrictHostKeyChecking=no ubuntu@app.tundracode.ru sudo chown ubuntu /var/www/tundracode.ru -R;
        scp -q -o StrictHostKeyChecking=no -r $CI_PROJECT_DIR/wp/* ubuntu@app.tundracode.ru:/var/www/tundracode.ru/;
        ssh -o StrictHostKeyChecking=no ubuntu@app.tundracode.ru sudo chown www-data /var/www/tundracode.ru -R;
      fi
    - echo "The End"
```

![](img/Screenshot%202022-09-06%20at%2017.42.39.png)

При любом коммите в репозиторий с WordPress и создании тега (например, v1.0.0) происходит деплой на виртуальную машину.

![](img/Screenshot%202022-09-06%20at%2019.12.02.png)

![](img/Screenshot%202022-09-06%20at%2019.13.05.png)


___
### Установка Prometheus, Alert Manager, Node Exporter и Grafana

Интерфейсы Prometheus, Alert Manager и Grafana доступны по https. На всех серверах установлен Node Exporter и его метрики доступны Prometheus.

![](img/Screenshot%202022-09-06%20at%2011.57.30.png)

![](img/Screenshot%202022-09-06%20at%2011.58.30.png)

Alert Manager:

![](img/Screenshot%202022-09-06%20at%2012.03.35.png)

![](img/Screenshot%202022-09-06%20at%2012.03.57.png)


Grafana: 

![](img/Screenshot%202022-09-06%20at%2012.57.30.png)

![](img/Screenshot%202022-09-06%20at%2012.59.00.png)

---

###Удаление инфраструктуры


```bash
cd terraform || return
terraform destroy --auto-approve

cd ../s3_init || return
terraform destroy --auto-approve
```
