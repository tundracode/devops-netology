# Домашнее задание к занятию "3.5. Файловые системы"

1. Узнайте о [sparse](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D1%80%D0%B5%D0%B6%D1%91%D0%BD%D0%BD%D1%8B%D0%B9_%D1%84%D0%B0%D0%B9%D0%BB) (разряженных) файлах.

`sparse file` — файл, в котором последовательности нулевых байтов заменены на информацию об этих последовательностях `hole`.

`hole` — последовательность нулевых байт внутри файла, не записанная на диск. Информация о дырах (смещение от начала файла в байтах и количество байт) хранится в метаданных ФС.

2. Могут ли файлы, являющиеся жесткой ссылкой на один объект, иметь разные права доступа и владельца? Почему?


Жесткая ссылка это ссылка на тот же самый файл и имеет тот же inode, который и содержит информацию о правах доступа и владельце. 


3. Сделайте `vagrant destroy` на имеющийся инстанс Ubuntu. Замените содержимое Vagrantfile следующим:

    ```bash
    Vagrant.configure("2") do |config|
      config.vm.box = "bento/ubuntu-20.04"
      config.vm.provider :virtualbox do |vb|
        lvm_experiments_disk0_path = "/tmp/lvm_experiments_disk0.vmdk"
        lvm_experiments_disk1_path = "/tmp/lvm_experiments_disk1.vmdk"
        vb.customize ['createmedium', '--filename', lvm_experiments_disk0_path, '--size', 2560]
        vb.customize ['createmedium', '--filename', lvm_experiments_disk1_path, '--size', 2560]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 1, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk0_path]
        vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', 2, '--device', 0, '--type', 'hdd', '--medium', lvm_experiments_disk1_path]
      end
    end
    ```

    Данная конфигурация создаст новую виртуальную машину с двумя дополнительными неразмеченными дисками по 2.5 Гб.

```buildoutcfg
vagrant@vagrant:~$ lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm  /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm  [SWAP]
sdb                    8:16   0  2.5G  0 disk
sdc                    8:32   0  2.5G  0 disk
vagrant@vagrant:~$
```

4. Используя `fdisk`, разбейте первый диск на 2 раздела: 2 Гб, оставшееся пространство.

```buildoutcfg
root@vagrant:~# fdisk -l /dev/sdb
Disk /dev/sdb: 2.51 GiB, 2684354560 bytes, 5242880 sectors
Disk model: VBOX HARDDISK
Units: sectors of 1 * 512 = 512 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disklabel type: dos
Disk identifier: 0x707aae69

Device     Boot   Start     End Sectors  Size Id Type
/dev/sdb1          2048 4196351 4194304    2G 83 Linux
/dev/sdb2       4196352 5242879 1046528  511M 83 Linux
```

5. Используя `sfdisk`, перенесите данную таблицу разделов на второй диск.

```buildoutcfg
root@vagrant:~# sfdisk -d /dev/sdb > sdb.dump
root@vagrant:~# sfdisk /dev/sdc < sdb.dump
```

6. Соберите `mdadm` RAID1 на паре разделов 2 Гб.

```buildoutcfg
root@vagrant:~# mdadm --create --verbose /dev/md0 --level=1 --raid-devices=2 /dev/sdb1 /dev/sdc1
```

7. Соберите `mdadm` RAID0 на второй паре маленьких разделов.

```buildoutcfg
root@vagrant:~# mdadm --create --verbose /dev/md1 --level=0 --raid-devices=2 /dev/sdb2 /dev/sdc2
```

8. Создайте 2 независимых PV на получившихся md-устройствах.

```buildoutcfg
root@vagrant:~# pvcreate /dev/md0
  Physical volume "/dev/md0" successfully created.
root@vagrant:~# pvcreate /dev/md1
  Physical volume "/dev/md1" successfully created.
root@vagrant:~# pvs
  PV         VG        Fmt  Attr PSize    PFree
  /dev/md0             lvm2 ---    <2.00g   <2.00g
  /dev/md1             lvm2 ---  1018.00m 1018.00m
  /dev/sda5  vgvagrant lvm2 a--   <63.50g       0
```
9. Создайте общую volume-group на этих двух PV.
```buildoutcfg
root@vagrant:~# vgcreate vg01 /dev/md0 /dev/md1
  Volume group "vg01" successfully created
root@vagrant:~# vgs
  VG        #PV #LV #SN Attr   VSize   VFree
  vg01        2   0   0 wz--n-  <2.99g <2.99g
  vgvagrant   1   2   0 wz--n- <63.50g     0
```

10. Создайте LV размером 100 Мб, указав его расположение на PV с RAID0.
```buildoutcfg
root@vagrant:~# lvcreate -L 100M vg01 /dev/md1
  Logical volume "lvol0" created.
root@vagrant:~# lvs
  LV     VG        Attr       LSize   Pool Origin Data%  Meta%  Move Log Cpy%Sync Convert
  lvol0  vg01      -wi-a----- 100.00m
  root   vgvagrant -wi-ao---- <62.54g
  swap_1 vgvagrant -wi-ao---- 980.00m
```

11. Создайте `mkfs.ext4` ФС на получившемся LV.
```buildoutcfg
root@vagrant:~# mkfs.ext4 /dev/vg01/lvol0
mke2fs 1.45.5 (07-Jan-2020)
Creating filesystem with 25600 4k blocks and 25600 inodes

Allocating group tables: done
Writing inode tables: done
Creating journal (1024 blocks): done
Writing superblocks and filesystem accounting information: done
```
12. Смонтируйте этот раздел в любую директорию, например, `/tmp/new`.
```buildoutcfg
root@vagrant:~# mount /dev/vg01/lvol0 /tmp/new
root@vagrant:~# mount | grep lvol0
/dev/mapper/vg01-lvol0 on /tmp/new type ext4 (rw,relatime,stripe=256)
```

13. Поместите туда тестовый файл, например `wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz`.
```buildoutcfg
root@vagrant:~# wget https://mirror.yandex.ru/ubuntu/ls-lR.gz -O /tmp/new/test.gz
--2021-12-02 12:36:53--  https://mirror.yandex.ru/ubuntu/ls-lR.gz
Resolving mirror.yandex.ru (mirror.yandex.ru)... 213.180.204.183
Connecting to mirror.yandex.ru (mirror.yandex.ru)|213.180.204.183|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 22742931 (22M) [application/octet-stream]
Saving to: ‘/tmp/new/test.gz’

/tmp/new/test.gz                    100%[==================================================================>]  21.69M  2.06MB/s    in 8.9s

2021-12-02 12:37:02 (2.45 MB/s) - ‘/tmp/new/test.gz’ saved [22742931/22742931]
```

14. Прикрепите вывод `lsblk`.
```buildoutcfg
root@vagrant:~# lsblk
NAME                 MAJ:MIN RM  SIZE RO TYPE  MOUNTPOINT
sda                    8:0    0   64G  0 disk
├─sda1                 8:1    0  512M  0 part  /boot/efi
├─sda2                 8:2    0    1K  0 part
└─sda5                 8:5    0 63.5G  0 part
  ├─vgvagrant-root   253:0    0 62.6G  0 lvm   /
  └─vgvagrant-swap_1 253:1    0  980M  0 lvm   [SWAP]
sdb                    8:16   0  2.5G  0 disk
├─sdb1                 8:17   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdb2                 8:18   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─vg01-lvol0     253:2    0  100M  0 lvm   /tmp/new
sdc                    8:32   0  2.5G  0 disk
├─sdc1                 8:33   0    2G  0 part
│ └─md0                9:0    0    2G  0 raid1
└─sdc2                 8:34   0  511M  0 part
  └─md1                9:1    0 1018M  0 raid0
    └─vg01-lvol0     253:2    0  100M  0 lvm   /tmp/new
```
15. Протестируйте целостность файла:

     ```bash
     root@vagrant:~# gzip -t /tmp/new/test.gz
     root@vagrant:~# echo $?
     0
     ```
```buildoutcfg
root@vagrant:~# gzip -t /tmp/new/test.gz && echo $?
0
```
16. Используя pvmove, переместите содержимое PV с RAID0 на RAID1.
```buildoutcfg
root@vagrant:~# pvmove  /dev/md1 /dev/md0
  /dev/md1: Moved: 8.00%
  /dev/md1: Moved: 100.00%
```
17. Сделайте `--fail` на устройство в вашем RAID1 md.
```buildoutcfg
root@vagrant:~# mdadm --fail /dev/md0 /dev/sdb1
mdadm: set /dev/sdb1 faulty in /dev/md0
```
18. Подтвердите выводом `dmesg`, что RAID1 работает в деградированном состоянии.
```buildoutcfg
mdadm: set /dev/sdb1 faulty in /dev/md0
root@vagrant:~# dmesg |grep md0
[ 1068.869277] md/raid1:md0: not clean -- starting background reconstruction
[ 1068.869279] md/raid1:md0: active with 2 out of 2 mirrors
[ 1068.869295] md0: detected capacity change from 0 to 2144337920
[ 1068.871447] md: resync of RAID array md0
[ 1079.232731] md: md0: resync done.
[ 3868.480885] md/raid1:md0: Disk failure on sdb1, disabling device.
               md/raid1:md0: Operation continuing on 1 devices.
```
19. Протестируйте целостность файла, несмотря на "сбойный" диск он должен продолжать быть доступен:

     ```bash
     root@vagrant:~# gzip -t /tmp/new/test.gz
     root@vagrant:~# echo $?
     0
     ```
```buildoutcfg
root@vagrant:~# gzip -t /tmp/new/test.gz && echo $?
0
```
20. Погасите тестовый хост, `vagrant destroy`.
```buildoutcfg
 ~/DEVSYS/vagrant  vagrant destroy
    default: Are you sure you want to destroy the 'default' VM? [y/N] y
==> default: Forcing shutdown of VM...
==> default: Destroying VM and associated drives...
```