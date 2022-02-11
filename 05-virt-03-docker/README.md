
# Домашнее задание к занятию "5.3. Введение. Экосистема. Архитектура. Жизненный цикл Docker контейнера"


## Задача 1

Сценарий выполения задачи:

- создайте свой репозиторий на https://hub.docker.com;
- выберете любой образ, который содержит веб-сервер Nginx;
- создайте свой fork образа;
- реализуйте функциональность:
запуск веб-сервера в фоне с индекс-страницей, содержащей HTML-код ниже:
```
<html>
<head>
Hey, Netology
</head>
<body>
<h1>I’m DevOps Engineer!</h1>
</body>
</html>
```
Опубликуйте созданный форк в своем репозитории и предоставьте ответ в виде ссылки на https://hub.docker.com/username_repo.


https://hub.docker.com/r/shmnd/nginx-netology

## Задача 2

Посмотрите на сценарий ниже и ответьте на вопрос:
"Подходит ли в этом сценарии использование Docker контейнеров или лучше подойдет виртуальная машина, физическая машина? Может быть возможны разные варианты?"

Детально опишите и обоснуйте свой выбор.

--

Сценарий:

- Высоконагруженное монолитное java веб-приложение --
_**физический сервер, т.к. монолитное, следовательно в микросерверах не реализуемо без изменения кода, и так как высоконагруженное -  то необходим физический доступ к ресурсами, без использования гипервизора виртуалки.**_
- Nodejs веб-приложение -- _**Докер подойдёт, т.к. это позволит быстро развернуть приложение со всеми необходимыми библиотеками.**_
- Мобильное приложение c версиями для Android и iOS -- _**Виртаульная машина -  т.к приложение в докере не имеет GUI**_ 
- Шина данных на базе Apache Kafka -- _**доставка приложения через докер на сервера и разработчикам в тестовую среду должна упростить жизнь. Возможность быстро откатиться если приложение обновили, и в продакшене что-то пошло не так**_
- Elasticsearch кластер для реализации логирования продуктивного веб-приложения - три ноды elasticsearch, два logstash и две ноды kibana -- _**Docker подойдёт лучше, так как он будет удобней для кластеризации**_
- Мониторинг-стек на базе Prometheus и Grafana -- _**Prometheus и Grafana можно использовать в Докере.**_
- MongoDB, как основное хранилище данных для java-приложения -- _**подойдёт Docker. У MongoDB даже есть официальный образ на Docker Hub.**_
- Gitlab сервер для реализации CI/CD процессов и приватный (закрытый) Docker Registry -- _**удобней будет виртуальная машина, т.к. серверу GitLab не требуется масштабирование или деплой новой версии несколько раз в день, а виртуальная машина позволит очень удобно делать бекапы и при необходимости мигрировать её в кластер**_


## Задача 3

- Запустите первый контейнер из образа ***centos*** c любым тэгом в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Запустите второй контейнер из образа ***debian*** в фоновом режиме, подключив папку ```/data``` из текущей рабочей директории на хостовой машине в ```/data``` контейнера;
- Подключитесь к первому контейнеру с помощью ```docker exec``` и создайте текстовый файл любого содержания в ```/data```;
- Добавьте еще один файл в папку ```/data``` на хостовой машине;
- Подключитесь во второй контейнер и отобразите листинг и содержание файлов в ```/data``` контейнера.

```shell
vagrant@master:~$ docker run -it --rm -d --name centos -v /data:/data centos:latest
Unable to find image 'centos:latest' locally
latest: Pulling from library/centos
a1d0c7532777: Pull complete
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
a47735c4147498c76032ac3abf65fb7eb7bcc810cce66378f6c8c7c4547ad70a
```

```shell
vagrant@master:~$ docker run -it --rm -d --name debian -v /data:/data debian:latest
Unable to find image 'debian:latest' locally
latest: Pulling from library/debian
0c6b8ff8c37e: Pull complete
Digest: sha256:fb45fd4e25abe55a656ca69a7bef70e62099b8bb42a279a5e0ea4ae1ab410e0d
Status: Downloaded newer image for debian:latest
d94096a1ea3d607dc7de45cc4badc24efc1a20747bef8aeabac32fc609a7f08c
```
```shell
vagrant@master:~$ docker exec -it centos bash
[root@a47735c41474 /]# ls
bin  data  dev	etc  home  lib	lib64  lost+found  media  mnt  opt  proc  root	run  sbin  srv	sys  tmp  usr  var
[root@a47735c41474 /]# touch /data/centos.txt
[root@a47735c41474 /]# ls /data/
centos.txt
```
```shell
vagrant@master:~$ ls -l /data/
total 4
-rw-r--r-- 1 root root 28 Feb 11 16:44 centos.txt
-rw-r--r-- 1 root root  0 Feb 11 16:50 vagrant.txt
```

```shell
vagrant@master:~$ docker attach debian
root@d94096a1ea3d:/# ls -l /data
total 4
-rw-r--r-- 1 root root 28 Feb 11 16:44 centos.txt
-rw-r--r-- 1 root root  0 Feb 11 16:50 vagrant.txt
root@d94096a1ea3d:/#
```