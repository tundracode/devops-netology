# Практическое задание по теме «Введение в Ansible»

## Подготовка к выполнению

1. Установите ansible версии 2.10 или выше.
2. Создайте свой собственный публичный репозиторий на github с произвольным именем.
3. Скачайте [playbook](./playbook/) из репозитория с домашним заданием и перенесите его в свой репозиторий.

### Ход работы

1. Проверим версию Ansible:

![](img/Screenshot%202022-09-09%20at%2022.34.25.png)

2. Загрузим [playbook](./playbook/).

## Основная часть

1. Попробуйте запустить playbook на окружении из `test.yml`, зафиксируйте какое значение имеет факт `some_fact` для указанного хоста при выполнении playbook'a.
2. Найдите файл с переменными (group_vars) в котором задаётся найденное в первом пункте значение и поменяйте его на 'all default fact'.
3. Воспользуйтесь подготовленным (используется `docker`) или создайте собственное окружение для проведения дальнейших испытаний.
4. Проведите запуск playbook на окружении из `prod.yml`. Зафиксируйте полученные значения `some_fact` для каждого из `managed host`.
5. Добавьте факты в `group_vars` каждой из групп хостов так, чтобы для `some_fact` получились следующие значения: для `deb` - 'deb default fact', для `el` - 'el default fact'.
6.  Повторите запуск playbook на окружении `prod.yml`. Убедитесь, что выдаются корректные значения для всех хостов.
7. При помощи `ansible-vault` зашифруйте факты в `group_vars/deb` и `group_vars/el` с паролем `netology`.
8. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь в работоспособности.
9. Посмотрите при помощи `ansible-doc` список плагинов для подключения. Выберите подходящий для работы на `control node`.
10. В `prod.yml` добавьте новую группу хостов с именем  `local`, в ней разместите localhost с необходимым типом подключения.
11. Запустите playbook на окружении `prod.yml`. При запуске `ansible` должен запросить у вас пароль. Убедитесь что факты `some_fact` для каждого из хостов определены из верных `group_vars`.
12. Заполните `README.md` ответами на вопросы. Сделайте `git push` в ветку `master`. В ответе отправьте ссылку на ваш открытый репозиторий с изменённым `playbook` и заполненным `README.md`.

### Ход работы

1. Запустим playbook `site.yml`, используя окружение `inventory/test.yml`:

![](img/Screenshot%202022-09-09%20at%2022.41.35.png)

Значение `some_fact` равно `12`.

2. Изменим [значение](playbook/group_vars/all/examp.yml) `some_fact` на `all default fact`.

![](img/Screenshot%202022-09-09%20at%2022.42.14.png)

3. Настроим окружения Centos7 и Ubuntu для проведения испытаний:

![](img/Screenshot%202022-09-09%20at%2022.48.19.png)

4. Запустим playbook `site.yml`, используя окружение `inventory/prod.yml`:


Значения `some_fact` для centos7 — `el`, для ubuntu — `deb`.

5. Внесём изменения в [group_vars](playbook/group_vars).

![](img/Screenshot%202022-09-09%20at%2022.56.49.png)

6. Снова запустим playbook `site.yml`:

![](img/Screenshot%202022-09-09%20at%2023.24.38.png)

7. Зашифруем значения `group_vars` с помощью команды `ansible-vault`:

![](img/Screenshot%202022-09-09%20at%2023.02.09.png)

Используемый пароль: `netology`.

8. Запустим playbook с флагом `--ask-vault-pass`:

![](img/Screenshot%202022-09-09%20at%2023.27.34.png)

9. Список плагинов для control node:

```shell
ansible-doc -l -t module
```
![](img/Screenshot%202022-09-09%20at%2023.08.30.png)

10. Добавим localhost в [prod.yml](playbook/inventory/prod.yml).

11. Запустим playbook:

![](img/Screenshot%202022-09-09%20at%2023.29.40.png)

## Самоконтроль выполненения задания

1. Где расположен файл с `some_fact` из второго пункта задания?

Файл расположен в [group_vars](playbook/group_vars/all).

2. Какая команда нужна для запуска вашего `playbook` на окружении `test.yml`?

`ansible-playbook -i inventory/test.yml site.yml`

3. Какой командой можно зашифровать файл?

`ansible-vault encrypt <file>`

4. Какой командой можно расшифровать файл?

`ansible-vault decrypt <file>`

5. Можно ли посмотреть содержимое зашифрованного файла без команды расшифровки файла? Если можно, то как?

`ansible-vault view <file>`

6. Как выглядит команда запуска `playbook`, если переменные зашифрованы?

`ansible-playbook --ask-vault-pass <yml>`

7. Как называется модуль подключения к host на windows?

[winrm](https://docs.ansible.com/ansible/2.5/plugins/connection/winrm.html)

8. Приведите полный текст команды для поиска информации в документации ansible для модуля подключений ssh

`ansible-doc -t connection ssh`

9. Какой параметр из модуля подключения `ssh` необходим для того, чтобы определить пользователя, под которым необходимо совершать подключение?

```shell
- remote_user
        User name with which to login to the remote server, normally set by the remote_user keyword.
        If no user is supplied, Ansible will let the SSH client binary choose the user as it normally.
        [Default: (null)]
```