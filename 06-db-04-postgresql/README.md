# Домашнее задание к занятию "6.4. PostgreSQL"

## Задача 1

Используя docker поднимите инстанс PostgreSQL (версию 13). Данные БД сохраните в volume.

Подключитесь к БД PostgreSQL используя `psql`.

Воспользуйтесь командой `\?` для вывода подсказки по имеющимся в `psql` управляющим командам.

**Найдите и приведите** управляющие команды для:
- вывода списка БД
- подключения к БД
- вывода списка таблиц
- вывода описания содержимого таблиц
- выхода из psql


###Ответ:

```shell
vagrant@master:~$ docker pull postgres:13
vagrant@master:~$ docker volume create vol_postgres
vol_postgres
vagrant@master:~$ docker run --rm --name pg-docker -e POSTGRES_PASSWORD=postgres -ti -p 5432:5432 -v vol_postgres:/var/lib/postgresql/data postgres:13
```




```shell
vagrant@master:~$ docker exec -it pg-docker bash
root@4335474d7454:/# psql -h localhost -p 5432 -U postgres -W
Password:
psql (13.6 (Debian 13.6-1.pgdg110+1))
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

```shell
postgres=# \c postgres
Password:
postgres=# \dtS
                    List of relations
   Schema   |          Name           | Type  |  Owner
------------+-------------------------+-------+----------
 pg_catalog | pg_aggregate            | table | postgres
 pg_catalog | pg_am                   | table | postgres
 pg_catalog | pg_amop                 | table | postgres
 pg_catalog | pg_amproc               | table | postgres
 pg_catalog | pg_attrdef              | table | postgres
...
```
```shell
postgres=# \dS+ pg_index
                                      Table "pg_catalog.pg_index"
     Column     |     Type     | Collation | Nullable | Default | Storage  | Stats target | Description
----------------+--------------+-----------+----------+---------+----------+--------------+-------------
 indexrelid     | oid          |           | not null |         | plain    |              |
 indrelid       | oid          |           | not null |         | plain    |              |
 indnatts       | smallint     |           | not null |         | plain    |              |
 indnkeyatts    | smallint     |           | not null |         | plain    |              |
 indisunique    | boolean      |           | not null |         | plain    
 ...

```
```shell
postgres=# \q
root@4335474d7454:/#
```
---

## Задача 2

Используя `psql` создайте БД `test_database`.

Изучите [бэкап БД](https://github.com/netology-code/virt-homeworks/tree/master/06-db-04-postgresql/test_data).

Восстановите бэкап БД в `test_database`.

Перейдите в управляющую консоль `psql` внутри контейнера.

Подключитесь к восстановленной БД и проведите операцию ANALYZE для сбора статистики по таблице.

Используя таблицу [pg_stats](https://postgrespro.ru/docs/postgresql/12/view-pg-stats), найдите столбец таблицы `orders` 
с наибольшим средним значением размера элементов в байтах.

**Приведите в ответе** команду, которую вы использовали для вычисления и полученный результат.

###Ответ:

```shell
postgres=# CREATE DATABASE test_database;
CREATE DATABASE
postgres=#
```

```shell
vagrant@master:~$ docker cp test_dump.sql pg-docker:/tmp
root@4335474d7454:/tmp# psql -U postgres -f test_dump.sql test_database
```

```shell
root@4335474d7454:/tmp# psql -h localhost -p 5432 -U postgres -W
Password:
psql (13.6 (Debian 13.6-1.pgdg110+1))
Type "help" for help.

postgres=# \c test_database
Password:
You are now connected to database "test_database" as user "postgres".
test_database=# \dt
         List of relations
 Schema |  Name  | Type  |  Owner
--------+--------+-------+----------
 public | orders | table | postgres
(1 row)

test_database=# ANALYZE VERBOSE public.orders;
INFO:  analyzing "public.orders"
INFO:  "orders": scanned 1 of 1 pages, containing 8 live rows and 0 dead rows; 8 rows in sample, 8 estimated total rows
ANALYZE
test_database=# select avg_width from pg_stats where tablename='orders';
 avg_width
-----------
         4
        16
         4
(3 rows)
```
---

## Задача 3

Архитектор и администратор БД выяснили, что ваша таблица orders разрослась до невиданных размеров и
поиск по ней занимает долгое время. Вам, как успешному выпускнику курсов DevOps в нетологии предложили
провести разбиение таблицы на 2 (шардировать на orders_1 - price>499 и orders_2 - price<=499).

Предложите SQL-транзакцию для проведения данной операции.

Можно ли было изначально исключить "ручное" разбиение при проектировании таблицы orders?

###Ответ:

```sql
BEGIN;
    CREATE TABLE public.orders_2 (
        CHECK(price<=499)
    ) INHERITS(orders);

    CREATE TABLE public.orders_1 (
        CHECK(price>499)
    ) INHERITS(orders);

    INSERT INTO public.orders_2 
    SELECT * FROM public.orders 
    WHERE price<=499;

    DELETE FROM ONLY public.orders
    WHERE price<=499;

    INSERT INTO public.orders_1 
    SELECT * FROM public.orders 
    WHERE price>499;

    DELETE FROM ONLY public.orders
    WHERE price>499;

    CREATE RULE orders_insert_less_or_equal_499 AS ON INSERT TO public.orders
    WHERE (price<=499)
    DO INSTEAD INSERT INTO public.orders_2 VALUES (NEW.*);

    CREATE RULE orders_insert_bigger_499 AS ON INSERT TO public.orders
    WHERE (price>499)
    DO INSTEAD INSERT INTO public.orders_1 VALUES (NEW.*);
    
    ALTER TABLE public.orders_1 OWNER TO postgres;
    ALTER TABLE public.orders_2 OWNER TO postgres;
END;
```

Можно было изначально заложить разбиение при проектировании таблиц.

---

## Задача 4

Используя утилиту `pg_dump` создайте бекап БД `test_database`.

Как бы вы доработали бэкап-файл, чтобы добавить уникальность значения столбца `title` для таблиц `test_database`?

```shell
root@4335474d7454:~# pg_dump -U postgres -d test_database > test_database_dump.sql
```
Чтобы добавить уникальность значения столбца `title` для таблиц `test_database` в секции создания таблицы `orders` нужно заменить условие `not null` на `unique` для колонки `title`

```sql
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id integer NOT NULL,
    title character varying(80) UNIQUE,
    price integer DEFAULT 0
)
PARTITION BY RANGE (price);
```


---

