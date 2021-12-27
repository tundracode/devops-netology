# Домашнее задание к занятию "4.2. Использование Python для решения типовых DevOps задач"

## Обязательные задания

1. Есть скрипт:
    ```python
    #!/usr/bin/env python3
    a = 1
    b = '2'
    c = a + b
    ```
    * Какое значение будет присвоено переменной c?
    * Как получить для переменной c значение 12?
    * Как получить для переменной c значение 3?


- Значение переменной не будет присвоено из-за несоответствия типов `TypeError: unsupported operand type(s) for +: 'int' and 'str'`


- Изменить тип переменной `a` - `c = str(a) + b` 


- Изменить тип переменоой `b` - `c = a + int(b)`


2. Мы устроились на работу в компанию, где раньше уже был DevOps Engineer. Он написал скрипт, позволяющий узнать, какие файлы модифицированы в репозитории, относительно локальных изменений. Этим скриптом недовольно начальство, потому что в его выводе есть не все изменённые файлы, а также непонятен полный путь к директории, где они находятся. Как можно доработать скрипт ниже, чтобы он исполнял требования вашего руководителя?

	```python
    #!/usr/bin/env python3

    import os

	bash_command = ["cd ~/netology/sysadm-homeworks", "git status"]
	result_os = os.popen(' && '.join(bash_command)).read()
    is_change = False
	for result in result_os.split('\n'):
        if result.find('modified') != -1:
            prepare_result = result.replace('\tmodified:   ', '')
            print(prepare_result)
            break

	```
fixed:
```python
#!/usr/bin/env python3

import os

path = "~/netology/sysadm-homeworks"
resolved_path = os.path.normpath(os.path.abspath(os.path.expanduser(os.path.expandvars(path))))

bash_command = [f"cd {resolved_path}", "git status"]
result_os = os.popen(' && '.join(bash_command)).read()
for result in result_os.split('\n'):
    if result.find('modified') != -1:
        prepare_result = result.replace('\tmodified:   ', '')
        print(os.path.join(resolved_path, prepare_result))
```
3. Доработать скрипт выше так, чтобы он мог проверять не только локальный репозиторий в текущей директории, а также умел воспринимать путь к репозиторию, который мы передаём как входной параметр. Мы точно знаем, что начальство коварное и будет проверять работу этого скрипта в директориях, которые не являются локальными репозиториями.

```python
#!/usr/bin/env python3

import os
import sys
import subprocess
import re

try:
    path = sys.argv[1]
except IndexError:
    path = "~/netology/sysadm-homeworks"

resolved_path = os.path.normpath(os.path.abspath(os.path.expanduser(os.path.expandvars(path))))

try:
    result_os = subprocess.Popen(["git", "status", "--porcelain"], stdout=subprocess.PIPE,stderr=subprocess.STDOUT, cwd=resolved_path, text=True).communicate()[0].split('\n')
except FileNotFoundError:
    print(
        f'{path} not exist '
    )
    exit()

if result_os[0].find('fatal:') >= 0:
    print(
        f'There is no git repository in {resolved_path}')
    exit()

list = {"M": "modified", "R": "renamed", "\?": "untracked"}

for result in result_os:
    for element in list.keys():
        regexp = re.compile(r"^ *" + element + "{1,2} *")
        if regexp.search(result):
            prepare_result = re.sub(regexp, '', result).split(' -> ')
            if list[element] == 'renamed':
                print(
                    f'{list[element]}:\t {os.path.join(resolved_path, prepare_result[1])} <- {prepare_result[0]}')
            else:
                print(
                    f'{list[element]}:\t {os.path.join(resolved_path, prepare_result[0])}')

```


4. Наша команда разрабатывает несколько веб-сервисов, доступных по http. Мы точно знаем, что на их стенде нет никакой балансировки, кластеризации, за DNS прячется конкретный IP сервера, где установлен сервис. Проблема в том, что отдел, занимающийся нашей инфраструктурой очень часто меняет нам сервера, поэтому IP меняются примерно раз в неделю, при этом сервисы сохраняют за собой DNS имена. Это бы совсем никого не беспокоило, если бы несколько раз сервера не уезжали в такой сегмент сети нашей компании, который недоступен для разработчиков. Мы хотим написать скрипт, который опрашивает веб-сервисы, получает их IP, выводит информацию в стандартный вывод в виде: <URL сервиса> - <его IP>. Также, должна быть реализована возможность проверки текущего IP сервиса c его IP из предыдущей проверки. Если проверка будет провалена - оповестить об этом в стандартный вывод сообщением: [ERROR] <URL сервиса> IP mismatch: <старый IP> <Новый IP>. Будем считать, что наша разработка реализовала сервисы: drive.google.com, mail.google.com, google.com.

```python
# /usr/bin/env python3

import socket
import time

hosts = {"drive.google.com": {"ipv4": "0.0.0.0"}, "mail.google.com": {
    "ipv4": "0.0.0.0"}, "google.com": {"ipv4": "0.0.0.0"}}

while True:
    for host in hosts.keys():
        cur_ip = hosts[host]["ipv4"]
        check_ip = socket.gethostbyname(host)
        if check_ip != cur_ip:
            print(f"""[ERROR] {host} IP mismatch: {cur_ip} {check_ip}""")
            hosts[host]["ipv4"] = check_ip
        else:
            print(f"""{host} - {cur_ip}""")
    time.sleep(2)
```