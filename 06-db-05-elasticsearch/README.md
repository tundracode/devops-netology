# Домашнее задание к занятию "6.5. Elasticsearch"

## Задача 1



Используя докер образ [centos:7](https://hub.docker.com/_/centos) как базовый и 
[документацию по установке и запуску Elastcisearch](https://www.elastic.co/guide/en/elasticsearch/reference/current/targz.html):

- составьте Dockerfile-манифест для elasticsearch
- соберите docker-образ и сделайте `push` в ваш docker.io репозиторий
- запустите контейнер из получившегося образа и выполните запрос пути `/` c хост-машины

Требования к `elasticsearch.yml`:
- данные `path` должны сохраняться в `/var/lib`
- имя ноды должно быть `netology_test`

В ответе приведите:
- текст Dockerfile манифеста
- ссылку на образ в репозитории dockerhub
- ответ `elasticsearch` на запрос пути `/` в json виде

Подсказки:
- возможно вам понадобится установка пакета perl-Digest-SHA для корректной работы пакета shasum
- при сетевых проблемах внимательно изучите кластерные и сетевые настройки в elasticsearch.yml
- при некоторых проблемах вам поможет docker директива ulimit
- elasticsearch в логах обычно описывает проблему и пути ее решения

Далее мы будем работать с данным экземпляром elasticsearch.

---
###Ответ:

- текст Dockerfile манифеста

```shell
FROM centos:7
MAINTAINER Mike Sinica <kish_forever@bk.ru>

RUN yum update -y && \
      yum install wget -y && \
      yum install perl-Digest-SHA -y && \
      yum install java-1.8.0-openjdk.x86_64 -y

WORKDIR /usr/elastic/

RUN wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.1-linux-x86_64.tar.gz && \
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512

RUN shasum -a 512 -c elasticsearch-8.0.1-linux-x86_64.tar.gz.sha512 && \
tar -xzf elasticsearch-8.0.1-linux-x86_64.tar.gz

COPY ./elasticsearch.yml /usr/elastic/elasticsearch-8.0.1/config/elasticsearch.yml

RUN groupadd -g 3000 elasticsearch && \
    adduser -u 3000 -g elasticsearch -s /bin/sh elasticsearch && \
    chmod 777 -R /var/lib/ && \
    chmod 777 -R /usr/elastic/elasticsearch-8.0.1/

USER 3000
EXPOSE 9200
EXPOSE 9300

WORKDIR /usr/elastic/elasticsearch-8.0.1/bin/
CMD ["./elasticsearch"]2
```

- ссылка на образ в репозитории dockerhub:


https://hub.docker.com/repository/docker/shmnd/elasticksearch_conf


- ответ `elasticsearch` на запрос пути `/` в json виде:

```shell
vagrant@master:~$ docker run -p 9200:9200 --name elastic --memory="1g" -d shmnd/elasticksearch_conf:netology    
b23b4cd0b0b7220e4071de634addc11f47d5ba20f3737ace8ff556f2d5bd5f17
vagrant@master:~$ curl -X GET "localhost:9200/?pretty"
{
  "name" : "netology_test",
  "cluster_name" : "elasticsearch",
  "cluster_uuid" : "y7dtuqwWS1yqtBwbJwPTOA",
  "version" : {
    "number" : "8.0.1",
    "build_flavor" : "default",
    "build_type" : "tar",
    "build_hash" : "801d9ccc7c2ee0f2cb121bbe22ab5af77a902372",
    "build_date" : "2022-02-24T13:55:40.601285296Z",
    "build_snapshot" : false,
    "lucene_version" : "9.0.0",
    "minimum_wire_compatibility_version" : "7.17.0",
    "minimum_index_compatibility_version" : "7.0.0"
  },
  "tagline" : "You Know, for Search"
}
```


## Задача 2

В этом задании вы научитесь:
- создавать и удалять индексы
- изучать состояние кластера
- обосновывать причину деградации доступности данных

Ознакомтесь с [документацией](https://www.elastic.co/guide/en/elasticsearch/reference/current/indices-create-index.html) 
и добавьте в `elasticsearch` 3 индекса, в соответствии со таблицей:

| Имя | Количество реплик | Количество шард |
|-----|-------------------|-----------------|
| ind-1| 0 | 1 |
| ind-2 | 1 | 2 |
| ind-3 | 2 | 4 |

Получите список индексов и их статусов, используя API и **приведите в ответе** на задание.

Получите состояние кластера `elasticsearch`, используя API.

Как вы думаете, почему часть индексов и кластер находится в состоянии yellow?

Удалите все индексы.

**Важно**

При проектировании кластера elasticsearch нужно корректно рассчитывать количество реплик и шард,
иначе возможна потеря данных индексов, вплоть до полной, при деградации системы.

---
### Ответ:

Создание индексов.

ind-1:

```shell
vagrant@master:~$ curl -X PUT "localhost:9200/ind-1?pretty" -H 'Content-Type: application/json' -d'
> {
> "settings":{
> "number_of_shards": 1,
> "number_of_replicas": 0
> }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-1"
}
```

ind-2:

```shell
vagrant@master:~$ curl -X PUT "localhost:9200/ind-2?pretty" -H 'Content-Type: application/json' -d'
> {
> "settings":{
> "number_of_shards": 2,
> "number_of_replicas": 1
> }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-2"
}
```

ind-3: 

```shell
vagrant@master:~$ curl -X PUT "localhost:9200/ind-3?pretty" -H 'Content-Type: application/json' -d'
> {
> "settings":{
> "number_of_shards": 4,
> "number_of_replicas": 2
> }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "ind-3"
}
```

Состояние шард:

```shell
vagrant@master:~$ curl -X GET "localhost:9200/_cat/shards?pretty&v=true"
index            shard prirep state      docs store ip         node
ind-3            1     p      STARTED       0  225b 172.17.0.2 netology_test
ind-3            1     r      UNASSIGNED
ind-3            1     r      UNASSIGNED
ind-3            2     p      STARTED       0  225b 172.17.0.2 netology_test
ind-3            2     r      UNASSIGNED
ind-3            2     r      UNASSIGNED
ind-3            3     p      STARTED       0  225b 172.17.0.2 netology_test
ind-3            3     r      UNASSIGNED
ind-3            3     r      UNASSIGNED
ind-3            0     p      STARTED       0  225b 172.17.0.2 netology_test
ind-3            0     r      UNASSIGNED
ind-3            0     r      UNASSIGNED
ind-2            1     p      STARTED       0  225b 172.17.0.2 netology_test
ind-2            1     r      UNASSIGNED
ind-2            0     p      STARTED       0  225b 172.17.0.2 netology_test
ind-2            0     r      UNASSIGNED
ind-1            0     p      STARTED       0  225b 172.17.0.2 netology_test
.geoip_databases 0     p      STARTED               172.17.0.2 netology_test
```
Cостояние кластера:

```shell
vagrant@master:~$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "elasticsearch",
  "status" : "yellow",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 8,
  "active_shards" : 8,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 10,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 44.44444444444444
}
```

Кластер в данный момент находится в Yellow статусе. Данные доступны, но есть проблемы с репликами. Количество активных шард 44,4%

Удалим индексы:

```shell
vagrant@master:~$ curl -X DELETE "localhost:9200/ind-1?pretty"
{
  "acknowledged" : true
}
vagrant@master:~$ curl -X DELETE "localhost:9200/ind-2?pretty"
{
  "acknowledged" : true
}
vagrant@master:~$ curl -X DELETE "localhost:9200/ind-3?pretty"
{
  "acknowledged" : true
}
```
После удаления индексов статус кластера сменился на Зеленый, т.к. количество активных шард теперь 100%:

```shell
vagrant@master:~$ curl -X GET "localhost:9200/_cluster/health?pretty"
{
  "cluster_name" : "elasticsearch",
  "status" : "green",
  "timed_out" : false,
  "number_of_nodes" : 1,
  "number_of_data_nodes" : 1,
  "active_primary_shards" : 1,
  "active_shards" : 1,
  "relocating_shards" : 0,
  "initializing_shards" : 0,
  "unassigned_shards" : 0,
  "delayed_unassigned_shards" : 0,
  "number_of_pending_tasks" : 0,
  "number_of_in_flight_fetch" : 0,
  "task_max_waiting_in_queue_millis" : 0,
  "active_shards_percent_as_number" : 100.0
}

```

## Задача 3

В данном задании вы научитесь:
- создавать бэкапы данных
- восстанавливать индексы из бэкапов

Создайте директорию `{путь до корневой директории с elasticsearch в образе}/snapshots`.

Используя API [зарегистрируйте](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-register-repository.html#snapshots-register-repository) 
данную директорию как `snapshot repository` c именем `netology_backup`.

**Приведите в ответе** запрос API и результат вызова API для создания репозитория.

Создайте индекс `test` с 0 реплик и 1 шардом и **приведите в ответе** список индексов.

[Создайте `snapshot`](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-take-snapshot.html) 
состояния кластера `elasticsearch`.

**Приведите в ответе** список файлов в директории со `snapshot`ами.

Удалите индекс `test` и создайте индекс `test-2`. **Приведите в ответе** список индексов.

[Восстановите](https://www.elastic.co/guide/en/elasticsearch/reference/current/snapshots-restore-snapshot.html) состояние
кластера `elasticsearch` из `snapshot`, созданного ранее. 

**Приведите в ответе** запрос к API восстановления и итоговый список индексов.

Подсказки:
- возможно вам понадобится доработать `elasticsearch.yml` в части директивы `path.repo` и перезапустить `elasticsearch`

---

###Ответ:

Создаем директорию. Вносим изменения в elasticsearch.yml и перезапускаем контейнер:

```shell
vagrant@master:~$ docker ps
CONTAINER ID   IMAGE                                COMMAND             CREATED       STATUS       PORTS                                                 NAMES
b23b4cd0b0b7   shmnd/elasticksearch_conf:netology   "./elasticsearch"   2 hours ago   Up 2 hours   0.0.0.0:9200->9200/tcp, :::9200->9200/tcp, 9300/tcp   elastic
vagrant@master:~$ docker container exec -it elastic /bin/bash
[elasticsearch@b23b4cd0b0b7 bin]$ mkdir /usr/elastic/elasticsearch-8.0.1/snapshots
[elasticsearch@b23b4cd0b0b7 bin]$ echo 'path.repo: /usr/elastic/elasticsearch-8.0.1/snapshots' >> /usr/elastic/elasticsearch-8.0.1/config/elasticsearch.yml
[elasticsearch@b23b4cd0b0b7 bin]$ exit
exit
vagrant@master:~$ docker restart b23b4cd0b0b7
b23b4cd0b0b7
```

Зарегистрируем директорию с типом "файловая система", используя API:

```shell
vagrant@master:~$ curl -X PUT "localhost:9200/_snapshot/netology_backup?pretty" -H 'Content-Type: application/json' -d'
> {
> "type": "fs",
> "settings": {
> "location": "netology_backup_location"
> }
> }
> '
{
  "acknowledged" : true
}
```

Информация о репозитории бекапов:

```shell
vagrant@master:~$ curl -X GET "localhost:9200/_snapshot/netology_backup?pretty"
{
  "netology_backup" : {
    "type" : "fs",
    "settings" : {
      "location" : "netology_backup_location"
    }
  }
}
```

Создадим индекс test:

```shell
vagrant@master:~$ curl -X PUT "localhost:9200/test?pretty" -H 'Content-Type: application/json' -d'
> {
> "settings":{
> "number_of_shards": 1,
> "number_of_replicas": 0
> }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test"
}
```

Список индексов:

```shell
vagrant@master:~$ curl -X GET "localhost:9200/_cat/indices?pretty&v=true"
health status index uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test  8r2jQOV7SMqQka1w3H9w7A   1   0          0            0       225b           225b
```

Сделаем snapshot:

```shell
vagrant@master:~$ curl -X PUT "localhost:9200/_snapshot/netology_backup/snapshot_test?wait_for_completion=true&pretty"
{
  "snapshot" : {
    "snapshot" : "snapshot_test",
    "uuid" : "Q7wEDXlaTSmHfme4Aia9mw",
    "repository" : "netology_backup",
    "version_id" : 8000199,
    "version" : "8.0.1",
    "indices" : [
      ".geoip_databases",
      "test"
    ],
    "data_streams" : [ ],
    "include_global_state" : true,
    "state" : "SUCCESS",
    "start_time" : "2022-04-15T10:33:32.873Z",
    "start_time_in_millis" : 1650018812873,
    "end_time" : "2022-04-15T10:33:34.719Z",
    "end_time_in_millis" : 1650018814719,
    "duration_in_millis" : 1846,
    "failures" : [ ],
    "shards" : {
      "total" : 2,
      "failed" : 0,
      "successful" : 2
    },
    "feature_states" : [
      {
        "feature_name" : "geoip",
        "indices" : [
          ".geoip_databases"
        ]
      }
    ]
  }
}
```

Список файлов в директории со snapshot`ами:

```shell 
[elasticsearch@b23b4cd0b0b7 netology_backup_location]$ ls -l
total 36
-rw-r--r-- 1 elasticsearch elasticsearch   846 Apr 15 10:33 index-0
-rw-r--r-- 1 elasticsearch elasticsearch     8 Apr 15 10:33 index.latest
drwxr-xr-x 4 elasticsearch elasticsearch  4096 Apr 15 10:33 indices
-rw-r--r-- 1 elasticsearch elasticsearch 17431 Apr 15 10:33 meta-Q7wEDXlaTSmHfme4Aia9mw.dat
-rw-r--r-- 1 elasticsearch elasticsearch   353 Apr 15 10:33 snap-Q7wEDXlaTSmHfme4Aia9mw.dat
```
Удалим индекс `test`

```shell
vagrant@master:~$ curl -X DELETE "localhost:9200/test?pretty"
{
  "acknowledged" : true
}
```

Создадим индекс test-2

```shell
vagrant@master:~$ curl -X PUT "localhost:9200/test-2?pretty" -H 'Content-Type: application/json' -d'
> {
> "settings":{
> "number_of_shards": 1,
> "number_of_replicas": 0
> }
> }
> '
{
  "acknowledged" : true,
  "shards_acknowledged" : true,
  "index" : "test-2"
}
```

```shell
vagrant@master:~$ curl -X GET "localhost:9200/_cat/indices?pretty&v=true"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 v-dxhRH8SFOkbnRAsj7UfQ   1   0          0            0       225b           225b
```
Восстановим данные из snapshot'а:

```shell
vagrant@master:~$ curl -X POST "localhost:9200/_snapshot/netology_backup/snapshot_test/_restore?pretty"
{
  "accepted" : true
}
```

Список индексов после восстановления:

```shell
vagrant@master:~$ curl -X GET "localhost:9200/_cat/indices?pretty&v=true"
health status index  uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   test-2 v-dxhRH8SFOkbnRAsj7UfQ   1   0          0            0       225b           225b
green  open   test   F7p0H-vbTVy23-X2FoV8SA   1   0          0            0       225b           225b
```
