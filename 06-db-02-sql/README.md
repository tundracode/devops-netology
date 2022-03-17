# Домашнее задание к занятию "6.2. SQL"


## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 12) c 2 volume, 
в который будут складываться данные БД и бэкапы.

Приведите получившуюся команду или docker-compose манифест.

---

### Ответ:
```
vagrant@master:~$ docker pull postgres:12
vagrant@master:~$ docker volume create vol1
vol1
vagrant@master:~$ docker volume create vol2
vol2
vagrant@master:~$ docker run --rm --name pg-docker -e POSTGRES_PASSWORD=pguser -e POSTGRES_USER=pguser -d -p 5432:5432 -v vol1:/var/lib/postgresql/data -v vol2:/var/lib/postgresql postgres:12

postgres@5261029c7bc1:/$ psql
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgres=# \l
                                 List of databases
   Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges
-----------+----------+----------+------------+------------+-----------------------
 postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 |
 template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
 template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
           |          |          |            |            | postgres=CTc/postgres
(3 rows)
```

---

## Задача 2

В БД из задачи 1: 
- создайте пользователя test-admin-user и БД test_db
- в БД test_db создайте таблицу orders и clients (спeцификация таблиц ниже)
- предоставьте привилегии на все операции пользователю test-admin-user на таблицы БД test_db
- создайте пользователя test-simple-user  
- предоставьте пользователю test-simple-user права на SELECT/INSERT/UPDATE/DELETE данных таблиц БД test_db

Таблица orders:
- id (serial primary key)
- наименование (string)
- цена (integer)

Таблица clients:
- id (serial primary key)
- фамилия (string)
- страна проживания (string, index)
- заказ (foreign key orders)

Приведите:
- итоговый список БД после выполнения пунктов выше,
- описание таблиц (describe)
- SQL-запрос для выдачи списка пользователей с правами над таблицами test_db
- список пользователей с правами над таблицами test_db

### Ответ:

```
vagrant@master:~$ docker exec -it pg-docker /bin/bash -c "psql -U postgres"
psql (12.10 (Debian 12.10-1.pgdg110+1))
Type "help" for help.

postgres=#
```

```sql
CREATE USER "test-admin-user";
CREATE DATABASE "test_db";

CREATE TABLE orders (
    id          serial primary key,
    "наименование" text NOT NULL,
    "цена"         integer NOT NULL
);

CREATE TABLE clients (
    id          serial primary key,
    "фамилия" text NOT NULL,
    "страна проживания" text,
    "заказ" integer ,
    FOREIGN KEY ("заказ") REFERENCES orders (id)
);

CREATE INDEX country on clients ("страна проживания");

GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO "test-admin-user";

CREATE USER "test-simple-user";
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO "test-simple-user";
```

```shell
test_db=# \l
                                List of databases
Name    |  Owner   | Encoding |  Collate   |   Ctype    |   Access privileges   
-----------+----------+----------+------------+------------+-----------------------
postgres  | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
template0 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
          |          |          |            |            | postgres=CTc/postgres
template1 | postgres | UTF8     | en_US.utf8 | en_US.utf8 | =c/postgres          +
          |          |          |            |            | postgres=CTc/postgres
test_db   | postgres | UTF8     | en_US.utf8 | en_US.utf8 | 
(4 rows)
```

```shell
test_db=# \d orders
                            Table "public.orders"
    Column    |  Type   | Collation | Nullable |              Default               
--------------+---------+-----------+----------+------------------------------------
id           | integer |           | not null | nextval('orders_id_seq'::regclass)
наименование | text    |           | not null | 
цена         | integer |           | not null | 
Indexes:
    "orders_pkey" PRIMARY KEY, btree (id)
Referenced by:
    TABLE "clients" CONSTRAINT "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```

```shell
test_db=# \d clients
                                Table "public.clients"
    Column       |  Type   | Collation | Nullable |               Default               
-------------------+---------+-----------+----------+-------------------------------------
id                | integer |           | not null | nextval('clients_id_seq'::regclass)
фамилия           | text    |           | not null | 
страна проживания | text    |           |          | 
заказ             | integer |           |          | 
Indexes:
    "clients_pkey" PRIMARY KEY, btree (id)
    "country" btree ("страна проживания")
Foreign-key constraints:
    "clients_заказ_fkey" FOREIGN KEY ("заказ") REFERENCES orders(id)
```

```shell
test_db=# SELECT grantee, table_name, privilege_type
test_db-# FROM information_schema."role_table_grants"
test_db-# WHERE "table_name" in ('orders', 'clients');
    grantee      | table_name | privilege_type 
------------------+------------+----------------
postgres         | orders     | INSERT
postgres         | orders     | SELECT
postgres         | orders     | UPDATE
postgres         | orders     | DELETE
postgres         | orders     | TRUNCATE
postgres         | orders     | REFERENCES
postgres         | orders     | TRIGGER
test-admin-user  | orders     | INSERT
test-admin-user  | orders     | SELECT
test-admin-user  | orders     | UPDATE
test-admin-user  | orders     | DELETE
test-admin-user  | orders     | TRUNCATE
test-admin-user  | orders     | REFERENCES
test-admin-user  | orders     | TRIGGER
test-simple-user | orders     | INSERT
test-simple-user | orders     | SELECT
test-simple-user | orders     | UPDATE
test-simple-user | orders     | DELETE
postgres         | clients    | INSERT
postgres         | clients    | SELECT
postgres         | clients    | UPDATE
postgres         | clients    | DELETE
postgres         | clients    | TRUNCATE
postgres         | clients    | REFERENCES
postgres         | clients    | TRIGGER
test-admin-user  | clients    | INSERT
test-admin-user  | clients    | SELECT
test-admin-user  | clients    | UPDATE
test-admin-user  | clients    | DELETE
test-admin-user  | clients    | TRUNCATE
test-admin-user  | clients    | REFERENCES
test-admin-user  | clients    | TRIGGER
test-simple-user | clients    | INSERT
test-simple-user | clients    | SELECT
test-simple-user | clients    | UPDATE
test-simple-user | clients    | DELETE
(36 rows)
```

```shell
test_db=# \dp
                                        Access privileges
Schema |      Name      |   Type   |         Access privileges          | Column privileges | Policies 
--------+----------------+----------+------------------------------------+-------------------+----------
public | clients        | table    | postgres=arwdDxt/postgres         +|                   | 
       |                |          | "test-admin-user"=arwdDxt/postgres+|                   | 
       |                |          | "test-simple-user"=arwd/postgres   |                   | 
public | clients_id_seq | sequence |                                    |                   | 
public | orders         | table    | postgres=arwdDxt/postgres         +|                   | 
       |                |          | "test-admin-user"=arwdDxt/postgres+|                   | 
       |                |          | "test-simple-user"=arwd/postgres   |                   | 
public | orders_id_seq  | sequence |                                    |                   | 
(4 rows)
```


## Задача 3

Используя SQL синтаксис - наполните таблицы следующими тестовыми данными:

Таблица orders

|Наименование|цена|
|------------|----|
|Шоколад| 10 |
|Принтер| 3000 |
|Книга| 500 |
|Монитор| 7000|
|Гитара| 4000|

Таблица clients

|ФИО|Страна проживания|
|------------|----|
|Иванов Иван Иванович| USA |
|Петров Петр Петрович| Canada |
|Иоганн Себастьян Бах| Japan |
|Ронни Джеймс Дио| Russia|
|Ritchie Blackmore| Russia|

Используя SQL синтаксис:
- вычислите количество записей для каждой таблицы 
- приведите в ответе:
    - запросы 
    - результаты их выполнения.

---
### Ответ:
```sql
INSERT INTO orders ("наименование", "цена") VALUES
    ('Шоколад', 10),
    ('Принтер', 3000),
    ('Книга', 500),
    ('Монитор',	7000),
    ('Гитара', 4000);

INSERT INTO clients ("фамилия", "страна проживания") VALUES
    ('Иванов Иван Иванович', 'USA'),
    ('Петров Петр Петрович', 'Canada'),
    ('Иоганн Себастьян Бах', 'Japan'),
    ('Ронни Джеймс Дио', 'Russia'),
    ('Ritchie Blackmore', 'Russia')
```

```shell
test_db=# SELECT count(id) FROM orders;
count 
-------
    5
(1 row)

test_db=# SELECT count(id) FROM clients;
count 
-------
    5
(1 row)
```
---

## Задача 4

Часть пользователей из таблицы clients решили оформить заказы из таблицы orders.

Используя foreign keys свяжите записи из таблиц, согласно таблице:

|ФИО|Заказ|
|------------|----|
|Иванов Иван Иванович| Книга |
|Петров Петр Петрович| Монитор |
|Иоганн Себастьян Бах| Гитара |

Приведите SQL-запросы для выполнения данных операций.

Приведите SQL-запрос для выдачи всех пользователей, которые совершили заказ, а также вывод данного запроса.
 
Подсказк - используйте директиву `UPDATE`.

---
### Ответ:

```sql
UPDATE clients SET "заказ"=subquery.id
FROM (SELECT id from orders where orders."наименование" = 'Книга') as subquery
WHERE "фамилия"='Иванов Иван Иванович';

UPDATE clients SET "заказ"=subquery.id
FROM (SELECT id from orders where orders."наименование" = 'Монитор') as subquery
WHERE "фамилия"='Петров Петр Петрович';

UPDATE clients SET "заказ"=subquery.id
FROM (SELECT id from orders where orders."наименование" = 'Гитара') as subquery
WHERE "фамилия"='Иоганн Себастьян Бах';
```

```shell
test_db=# SELECT * FROM clients where "заказ" IS NOT NULL;
id |       фамилия        | страна проживания | заказ 
----+----------------------+-------------------+-------
1 | Иванов Иван Иванович | USA               |     3
2 | Петров Петр Петрович | Canada            |     4
3 | Иоганн Себастьян Бах | Japan             |     5
(3 rows)
```
```shell
test_db=# 
test_db=# SELECT * FROM clients
test_db-# INNER JOIN orders on clients."заказ"=orders.id;
id |       фамилия        | страна проживания | заказ | id | наименование | цена 
----+----------------------+-------------------+-------+----+--------------+------
1 | Иванов Иван Иванович | USA               |     3 |  3 | Книга        |  500
2 | Петров Петр Петрович | Canada            |     4 |  4 | Монитор      | 7000
3 | Иоганн Себастьян Бах | Japan             |     5 |  5 | Гитара       | 4000
(3 rows)
```
---


## Задача 5

Получите полную информацию по выполнению запроса выдачи всех пользователей из задачи 4 
(используя директиву EXPLAIN).

Приведите получившийся результат и объясните что значат полученные значения.

---

### Ответ:

```shell
test_db=# EXPLAIN ANALYZE
test_db-# SELECT * FROM clients INNER JOIN orders on clients."заказ"=orders.id;
                                                QUERY PLAN                                                  
-------------------------------------------------------------------------------------------------------------
Hash Join  (cost=1.11..2.19 rows=5 width=112) (actual time=0.080..0.083 rows=3 loops=1)
Hash Cond: (clients."заказ" = orders.id)
->  Seq Scan on clients  (cost=0.00..1.05 rows=5 width=72) (actual time=0.005..0.006 rows=5 loops=1)
->  Hash  (cost=1.05..1.05 rows=5 width=40) (actual time=0.021..0.021 rows=5 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 9kB
        ->  Seq Scan on orders  (cost=0.00..1.05 rows=5 width=40) (actual time=0.005..0.006 rows=5 loops=1)
Planning Time: 0.412 ms
Execution Time: 0.133 ms
(8 rows)
```

---

## Задача 6

Создайте бэкап БД test_db и поместите его в volume, предназначенный для бэкапов (см. Задачу 1).

Остановите контейнер с PostgreSQL (но не удаляйте volumes).

Поднимите новый пустой контейнер с PostgreSQL.

Восстановите БД test_db в новом контейнере.

Приведите список операций, который вы применяли для бэкапа данных и восстановления. 

---

### Ответ:

```shell
$ echo 'backuping database'
$ sudo docker exec -ti 77792eb99a09 bash
$ pg_dump -U postgres test_db>/postgres_backup/test_db.sql
$ exit
$ echo 'creating new container with Postgres'
$ sudo docker run --rm --name postgres -dt \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres  \
-v /docker_volumes/postgres_backup:/postgres_backup \
postgres:12-alpine
$ sudo docker exec -ti postgres bash
$ echo 'restoring database'
$ createdb -U postgres test_db
$ createuser -U postgres "test-admin-user"
$ createuser -U postgres "test-simple-user"
$ psql -U postgres test_db</postgres_backup/test_db.sql
```

---
