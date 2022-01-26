
# Домашнее задание к занятию "5.2. Применение принципов IaaC в работе с виртуальными машинами"


## Задача 1

- Опишите своими словами основные преимущества применения на практике IaaC паттернов.

__- Уменьшение расходов на рутинные операции. Автоматизация инфраструктуры позволяет эффективнее использовать существующие ресурсы.__ 

__- Также автоматизация позволяет минимизировать риск возникновения человеческой ошибки__

__- Удобство маштабирования и централизованное хранение конфигураций.__

- Какой из принципов IaaC является основополагающим?

__- Идемпотентность - воспроизводимость одного и того же результата не зависимо от количество повторений, помогает проектировать более надёжные системы.__

## Задача 2

- Чем Ansible выгодно отличается от других систем управление конфигурациями?

**- Не требует агента на конфигурируемой системе**

**- Управление из единого центра, push режим конфигурации**

**- Не требует PKI инфраструктуры**


- Какой, на ваш взгляд, метод работы систем конфигурации более надёжный push или pull?

**- Надежность технологии PUSH заключается в инициативности и своевременности информации, а так же централизованном управлении.**



## Задача 3

Установить на личный компьютер:

- VirtualBox
- Vagrant
- Ansible

*Приложить вывод команд установленных версий каждой из программ, оформленный в markdown.*


```shell
root@master:~# dmesg | grep virt
[    0.001740] CPU MTRRs all blank - virtualized system.
[    0.123480] Booting paravirtualized kernel on KVM
[    2.817680] systemd[1]: Detected virtualization oracle.
```

```shell
 ~/DEVSYS/vagrant  vagrant version
Installed Version: 2.2.19
Latest Version: 2.2.19

You're running an up-to-date version of Vagrant!
```

```shell
root@master:~# ansible --version
ansible [core 2.12.1]
  config file = /etc/ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3/dist-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.8.10 (default, Nov 26 2021, 20:14:08) [GCC 9.3.0]
  jinja version = 2.10.1
  libyaml = True
```

## Задача 4 (*)

Воспроизвести практическую часть лекции самостоятельно.

- Создать виртуальную машину.
- Зайти внутрь ВМ, убедиться, что Docker установлен с помощью команды
```
docker ps
```
```shell
 ~/DEVSYS/vagrant2  cat Vagrantfile
ISO = "bento/ubuntu-20.04"
NET = "192.168.192."
DOMAIN = ".netology"
HOST_PREFIX = "server"
INVENTORY_PATH = "../ansible/inventory"


servers = [
  {
    :hostname => HOST_PREFIX + "1" + DOMAIN,
    :ip => NET + "11",
    :ssh_host => "20011",
    :ssh_vm => "22",
    :ram => 1024,
    :core => 1
  }
]
Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant", disabled: false
  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box = ISO
      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip: machine[:ip]
      node.vm.network :forwarded_port, guest: machine[:ssh_vm], host: machine[:ssh_host]
      node.vm.provider "virtualbox" do |vb|
        vb.customize ["modifyvm", :id, "--memory", machine[:ram]]
        vb.customize ["modifyvm", :id, "--cpus", machine[:core]]
        vb.name = machine[:hostname]
      end
      node.vm.provision "ansible" do |setup|
        setup.inventory_path = INVENTORY_PATH
        setup.playbook = "../ansible/provision.yml"
        setup.become = true
        setup.extra_vars = { ansible_user: 'vagrant' }
      end
    end
  end
end
```

```shell
 ~/DEVSYS/ansible  cat inventory
[nodes:children]
manager

[manager]
server1.netology ansible_host=127.0.0.1 ansible_port=20011 ansible_user=vagrant

 ~/DEVSYS/ansible  cat provision.yml
---

  - hosts: all
    become: yes
    become_user: root
    remote_user: vagrant

    tasks:
      - name: Checking DNS
        command: host -t A google.com

      - name: Installing tools
        apt: >
          package={{ item }}
          state=present
          update_cache=yes
        with_items:
          - git
          - curl

      - name: Installing docker
        shell: curl -fsSL get.docker.com -o get-docker.sh && chmod +x get-docker.sh && ./get-docker.sh

      - name: Add the current user to docker group
        user: name=vagrant append=yes groups=docker

 ~/DEVSYS/ansible  cat ansible.cfg
[defaults]
inventory=./inventory
deprecation_warnings=False
command_warnings=False
ansible_port=22
interpreter_python=/usr/bin/python5
```
```shell
vagrant@server1:~$ docker ps
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
```