# Домашнее задание к занятию "3.3. Операционные системы, лекция 1"

1. Какой системный вызов делает команда `cd`? В прошлом ДЗ мы выяснили, что `cd` не является самостоятельной  программой, это `shell builtin`, поэтому запустить `strace` непосредственно на `cd` не получится. Тем не менее, вы можете запустить `strace` на `/bin/bash -c 'cd /tmp'`. В этом случае вы увидите полный список системных вызовов, которые делает сам `bash` при старте. Вам нужно найти тот единственный, который относится именно к `cd`.

 `chdir("/tmp")`

2. Попробуйте использовать команду `file` на объекты разных типов на файловой системе. Например:
    ```bash
    vagrant@netology1:~$ file /dev/tty
    /dev/tty: character special (5/0)
    vagrant@netology1:~$ file /dev/sda
    /dev/sda: block special (8/0)
    vagrant@netology1:~$ file /bin/bash
    /bin/bash: ELF 64-bit LSB shared object, x86-64
    ```
    Используя `strace` выясните, где находится база данных `file` на основании которой она делает свои догадки.

```buildoutcfg
openat(AT_FDCWD, "/usr/share/misc/magic.mgc", O_RDONLY) = 3
```

«Файл `/usr/share/misc/magic` определяет, какие шаблоны должны быть проверены, какое сообщение или тип MIME печатать, если обнаружен конкретный шаблон, и дополнительную информацию, которую нужно извлечь из файла».

```buildoutcfg
vagrant@vagrant:~$ file /usr/share/misc/magic
/usr/share/misc/magic: symbolic link to ../file/magic
vagrant@vagrant:~$ file /lib/file/magic.mgc
/lib/file/magic.mgc: magic binary file for file(1) cmd (version 14) (little endian
```


3. Предположим, приложение пишет лог в текстовый файл. Этот файл оказался удален (deleted в lsof), однако возможности сигналом сказать приложению переоткрыть файлы или просто перезапустить приложение – нет. Так как приложение продолжает писать в удаленный файл, место на диске постепенно заканчивается. Основываясь на знаниях о перенаправлении потоков предложите способ обнуления открытого удаленного файла (чтобы освободить место на файловой системе).

Можно использовать утилиту truncate, которая уменьшает или увеличивает размер файла. <PID> - процесс открывший файл, <FD> - дескриптор открытого файла

```buildoutcfg
vagrant@vagrant:~$ sudo truncate -s 0 /proc/<PID>/fd/<FD>
```

4. Занимают ли зомби-процессы какие-то ресурсы в ОС (CPU, RAM, IO)?

Процесс при завершении освобождает все свои ресурсы (за исключением PID — идентификатора процесса) и становится «зомби» — пустой записью в таблице процессов, хранящей код завершения для родительского процесса. Зомби-процесс существует до тех пор, пока родительский процесс не прочитает его статус с помощью системного вызова `wait()`, в результате чего запись в таблице процессов будет освобождена.

5. В iovisor BCC есть утилита `opensnoop`:
    ```bash
    root@vagrant:~# dpkg -L bpfcc-tools | grep sbin/opensnoop
    /usr/sbin/opensnoop-bpfcc
    ```
    На какие файлы вы увидели вызовы группы `open` за первую секунду работы утилиты? Воспользуйтесь пакетом `bpfcc-tools` для Ubuntu 20.04. Дополнительные [сведения по установке](https://github.com/iovisor/bcc/blob/master/INSTALL.md).

```buildoutcfg
vagrant@vagrant:~$ sudo opensnoop-bpfcc
PID    COMM               FD ERR PATH
1      systemd            12   0 /proc/405/cgroup
773    vminfo              6   0 /var/run/utmp
592    dbus-daemon        -1   2 /usr/local/share/dbus-1/system-services
592    dbus-daemon        18   0 /usr/share/dbus-1/system-services
592    dbus-daemon        -1   2 /lib/dbus-1/system-services
592    dbus-daemon        18   0 /var/lib/snapd/dbus-1/system-services/
607    irqbalance          6   0 /proc/interrupts
607    irqbalance          6   0 /proc/stat
607    irqbalance          6   0 /proc/irq/20/smp_affinity
607    irqbalance          6   0 /proc/irq/0/smp_affinity
607    irqbalance          6   0 /proc/irq/1/smp_affinity
607    irqbalance          6   0 /proc/irq/8/smp_affinity
607    irqbalance          6   0 /proc/irq/12/smp_affinity
607    irqbalance          6   0 /proc/irq/14/smp_affinity
607    irqbalance          6   0 /proc/irq/15/smp_affinity
```

6. Какой системный вызов использует `uname -a`? Приведите цитату из man по этому системному вызову, где описывается альтернативное местоположение в `/proc`, где можно узнать версию ядра и релиз ОС.

`uname()` returns system information in the structure pointed to by buf. The utsname struct is defined in `<sys/utsname.h>`. Part of the utsname information is also accessible via `/proc/sys/kernel/{ostype, hostname, osrelease, version, domainname}`.  

7. Чем отличается последовательность команд через `;` и через `&&` в bash? Например:
    ```bash
    root@netology1:~# test -d /tmp/some_dir; echo Hi
    Hi
    root@netology1:~# test -d /tmp/some_dir && echo Hi
    root@netology1:~#
    ```
    Есть ли смысл использовать в bash `&&`, если применить `set -e`?

Средства группировки команд `;` определяют последовательное выполнение команд. `&&`	- выполнение последующей команды только при условии нормального завершения предыдущей, иначе игнорировать.
`set -e ` немедленный выход, если выходное состояние команды ненулевое. Вероятно не имеет смысла использовать `&&` если применить `set -e`. 

8. Из каких опций состоит режим bash `set -euxo pipefail` и почему его хорошо было бы использовать в сценариях?

`-е` - немедленный выход, если выходное состояние команды ненулевое.
`-u` - во время замещения рассматривает незаданную переменную как ошибку.
`-x` - выводит команды и их аргументы по мере выполнения команд.
`-o pipefail` - прекращает выполнение скрипта, даже если одна из частей пайпа завершилась ошибкой.
С этими настройками некоторые распространенные ошибки приведут к немедленному сбою скрипта, с детализацией. В противном случае можно получить скрытые ошибки, которые обнаруживаются только на этапе эксплуатации.

9. Используя `-o stat` для `ps`, определите, какой наиболее часто встречающийся статус у процессов в системе. В `man ps` ознакомьтесь (`/PROCESS STATE CODES`) что значат дополнительные к основной заглавной буквы статуса процессов. Его можно не учитывать при расчете (считать S, Ss или Ssl равнозначными).

```buildoutcfg
vagrant@vagrant:~$ ps -eo stat | grep -v STAT | sort | uniq -c | sort -gr
     40 I<
     25 S
     15 Ss
      8 I
      4 Ssl
      3 S+
      2 Ss+
      2 SN
      2 R+
      1 S<s
      1 SLsl
      1 Sl
```

дополнительные символы к основной букве статуса:
               `<` - высокий приоритет
               `N` - с низким приоритетом
               `L` - имеет страницы, заблокированные в памяти
               `s` - лидер сеанса
               `l` - много-потоковый (с использованием CLONE_THREAD)
               `+` - находится в группе процессов переднего плана