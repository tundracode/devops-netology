# Курсовая работа по итогам модуля "DevOps и системное администрирование"


## Задание

1. Создайте виртуальную машину Linux.

2. Установите ufw и разрешите к этой машине сессии на порты 22 и 443, при этом трафик на интерфейсе localhost (lo) должен ходить свободно на все порты.

```shell
root@master:~# ufw status verbose
Status: active
Logging: on (low)
Default: deny (incoming), allow (outgoing), disabled (routed)
New profiles: skip

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW IN    Anywhere
443                        ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
443 (v6)                   ALLOW IN    Anywhere (v6)
```
3. Установите hashicorp vault ([инструкция по ссылке](https://learn.hashicorp.com/tutorials/vault/getting-started-install?in=vault/getting-started#install-vault)).

```shell
root@master:~# curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
OK
root@master:~# sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
Hit:1 http://archive.ubuntu.com/ubuntu focal InRelease
Get:2 http://security.ubuntu.com/ubuntu focal-security InRelease [114 kB]
Get:3 https://apt.releases.hashicorp.com focal InRelease [9,495 B]
Get:4 http://archive.ubuntu.com/ubuntu focal-updates InRelease [114 kB]
Get:5 https://apt.releases.hashicorp.com focal/main amd64 Packages [41.1 kB]
Get:6 http://security.ubuntu.com/ubuntu focal-security/main i386 Packages [351 kB]
Hit:7 http://archive.ubuntu.com/ubuntu focal-backports InRelease
Get:8 http://archive.ubuntu.com/ubuntu focal-updates/main amd64 Packages [1,440 kB]
Get:9 http://security.ubuntu.com/ubuntu focal-security/main amd64 Packages [1,106 kB]
Get:10 http://archive.ubuntu.com/ubuntu focal-updates/main i386 Packages [580 kB]
Get:11 http://archive.ubuntu.com/ubuntu focal-updates/universe amd64 Packages [885 kB]
Get:12 http://archive.ubuntu.com/ubuntu focal-updates/universe i386 Packages [655 kB]
Fetched 5,296 kB in 3s (1,675 kB/s)
Reading package lists... Done
root@master:~# sudo apt-get update && sudo apt-get install vault
Hit:1 http://security.ubuntu.com/ubuntu focal-security InRelease
Hit:2 https://apt.releases.hashicorp.com focal InRelease
Hit:3 http://archive.ubuntu.com/ubuntu focal InRelease
Hit:4 http://archive.ubuntu.com/ubuntu focal-updates InRelease
Hit:5 http://archive.ubuntu.com/ubuntu focal-backports InRelease
Reading package lists... Done
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following NEW packages will be installed:
  vault
0 upgraded, 1 newly installed, 0 to remove and 109 not upgraded.
Need to get 69.4 MB of archives.
After this operation, 188 MB of additional disk space will be used.
Get:1 https://apt.releases.hashicorp.com focal/main amd64 vault amd64 1.9.2 [69.4 MB]
Fetched 69.4 MB in 1min 26s (805 kB/s)
Selecting previously unselected package vault.
(Reading database ... 41552 files and directories currently installed.)
Preparing to unpack .../archives/vault_1.9.2_amd64.deb ...
Unpacking vault (1.9.2) ...
Setting up vault (1.9.2) ...
Generating Vault TLS key and self-signed certificate...
Generating a RSA private key
.............................++++
.......................++++
writing new private key to 'tls.key'
-----
Vault TLS key and self-signed certificate have been generated in '/opt/vault/tls'.
```
4. Cоздайте центр сертификации по инструкции ([ссылка](https://learn.hashicorp.com/tutorials/vault/pki-engine?in=vault/secrets-management)) и выпустите сертификат для использования его в настройке веб-сервера nginx (срок жизни сертификата - месяц).

```shell
root@master:~# sudo apt-get install jq
root@master:~# export VAULT_ADDR=http://127.0.0.1:8200
root@master:~# export VAULT_TOKEN=root
root@master:~# vault secrets enable pki
Success! Enabled the pki secrets engine at: pki/
root@master:~# vault secrets tune -max-lease-ttl=87600h pki
Success! Tuned the secrets engine at: pki/
root@master:~# vault write -field=certificate pki/root/generate/internal \
>      common_name="example.com" \
>      ttl=87600h > CA_cert.crt
root@master:~# vault write pki/config/urls \
>      issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
>      crl_distribution_points="$VAULT_ADDR/v1/pki/crl"
Success! Data written to: pki/config/urls
root@master:~# vault secrets enable -path=pki_int pki
Success! Enabled the pki secrets engine at: pki_int/
root@master:~# vault secrets tune -max-lease-ttl=43800h pki_int
Success! Tuned the secrets engine at: pki_int/
root@master:~# vault write -format=json pki_int/intermediate/generate/internal \
>      common_name="example.com Intermediate Authority" \
>      | jq -r '.data.csr' > pki_intermediate.csr
root@master:~# vault write -format=json pki/root/sign-intermediate csr=@pki_intermediate.csr \
>      format=pem_bundle ttl="43800h" \
>      | jq -r '.data.certificate' > intermediate.cert.pem
root@master:~# vault write pki_int/intermediate/set-signed certificate=@intermediate.cert.pem
Success! Data written to: pki_int/intermediate/set-signed
root@master:~# vault write pki_int/roles/example-dot-com \
>      allowed_domains="example.com" \
>      allow_subdomains=true \
>      max_ttl="720h"
Success! Data written to: pki_int/roles/example-dot-com
root@master:~# vault write pki_int/issue/example-dot-com common_name="test.example.com" ttl="720h"
Key                 Value
---                 -----
ca_chain            [-----BEGIN CERTIFICATE-----
MIIDpjCCAo6gAwIBAgIUTkXDvbXrA8TbG0DxB1f5sdFxsfYwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjIwMTE0MTUwNjIxWhcNMjcw
MTEzMTUwNjUxWjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg
QXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwRyC6TWX
FjF9G3/jvYaJ/AsUo4sT44tqFk83Po05rxIyMisdxsq2D+cMhN4Mp4oIKY4syG5p
CF6vzdqLucZ9KeajaYJ5BOZWq0QA/YFEmqDvXacOLq7cnARcwcagnQ4WqUMPXpbS
ljhIyTQYw1nlC5wUIsDdTlNG3kDpg1yfBuIGZqzKiWx0Bm3Ey8YZPBAzXx/IMv26
lEDF2iBHwwHCh8PsWNo62JBtuZsEIh3Ox7ohxzfrJqEaEfUhW4eu5UGuSuW96ity
80dhU4F+f/pbQhIZazy/ys0XTIQVCCeorGe2ourvUM18PwpXb/RN7PhJonIO/lY4
nN38o4yqjKpZawIDAQABo4HUMIHRMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBRuY+auU+Iu7gbbCG121PGeEOBy5zAfBgNVHSMEGDAW
gBTkViyLeiMEcTjaSxhVPotDZ+GuKDA7BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUH
MAKGH2h0dHA6Ly8xMjcuMC4wLjE6ODIwMC92MS9wa2kvY2EwMQYDVR0fBCowKDAm
oCSgIoYgaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jcmwwDQYJKoZIhvcN
AQELBQADggEBAFBbJNu33XAdgbisJYycCWBb7z1n6qNkMKKzWx89W1l7w1fDNIxp
IaAaYMRS1NyBUNCw6gktCcsQnWpygjZWXYp6nrjj0CncdeEphsHu/ETkPDwf/BW2
t4ffaYwrPZCilPgBVjhCje0ULtbKq+a3F4Lx8VA/fVhdR3Bn0+pXieiQD9G5H3rt
FJRhaqaZFKN+B9/qoToRDLA3ilj+iRHhe6S6s5ndVzxtADerLoPjB7Zwlpta8ucu
QYNxC0Sb3emJAZL5dIsaomU+HLmxAVojqqbZyyHjcUreOszlRDL4iNB60qiFwejm
5nmeR1uf1L5niKyrAND/HFYZoeHrTObbaH8=
-----END CERTIFICATE-----]
certificate         -----BEGIN CERTIFICATE-----
MIIDZjCCAk6gAwIBAgIUYE5wInVxhe89vakjbGSvYGz6LTcwDQYJKoZIhvcNAQEL
BQAwLTErMCkGA1UEAxMiZXhhbXBsZS5jb20gSW50ZXJtZWRpYXRlIEF1dGhvcml0
eTAeFw0yMjAxMTQxNTEwMjdaFw0yMjAyMTMxNTEwNTdaMBsxGTAXBgNVBAMTEHRl
c3QuZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCz
G59+KedYpXZ5y0rdO5aAHxmKPJhLOWC0tt+ibL4yY3PKQxLZ5kwtjgnMYMPnv8DM
jNBLKf54ez70s6LNkSEfsL7sRRCiVcT9lecPrhiIgqg3XUcqpcjjny4ERLpLP4OS
D1lcxvDc7CulpTqUV6EQ0xsBDCrJYXRgA5uopGq0oGQs/rYvV088438Oa8YaKyfj
OP0GtsoQ7njvwZYpivelEX33gWgyTUvEu1oxWRPYZmRrxfoWrMw6A8EAhq1WDW/T
3zcdsFkLCtXR5rKm7bn5rPV5q5vbUrqmRUBLZ06hUNyiP7+18hvxIlO1hRYiOV9C
EjuwGDG2MwFOiBxkJQO5AgMBAAGjgY8wgYwwDgYDVR0PAQH/BAQDAgOoMB0GA1Ud
JQQWMBQGCCsGAQUFBwMBBggrBgEFBQcDAjAdBgNVHQ4EFgQU6TKr3YHGOQKonn/T
FWGLqeWo2zYwHwYDVR0jBBgwFoAUbmPmrlPiLu4G2whtdtTxnhDgcucwGwYDVR0R
BBQwEoIQdGVzdC5leGFtcGxlLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAMT+0s2s0
4iRWcgGzKyMk577EUqnvvD0Mc75/FvbS/5pzDo6/Tjlrx1knItxQsk/4tOoeKbQJ
7YRH2TDZNhh8x0EYd637QuixAUROPumlP7jPphe4roG/RsjBP4n0ulCnRVT5BK9J
mQC56Iib6NPF8e9oiRiCsfkQuRFAyTb/YUyD91PIAWHhMIwD3o+GRac91w/LA2HB
xTndqcuCdie+WUFyuO8gN3twwoCrqQVPxeIrqfOVCfu2L2NZDEzUGOBDqmSeWLa/
t06JjQ7HAbVsY8aq0HI6EczNsTmHDaoPc6GZ+35fuIlfFGhefyOGqcvbqyj89o+F
XgJIdsLQZfl1pg==
-----END CERTIFICATE-----
expiration          1644765057
issuing_ca          -----BEGIN CERTIFICATE-----
MIIDpjCCAo6gAwIBAgIUTkXDvbXrA8TbG0DxB1f5sdFxsfYwDQYJKoZIhvcNAQEL
BQAwFjEUMBIGA1UEAxMLZXhhbXBsZS5jb20wHhcNMjIwMTE0MTUwNjIxWhcNMjcw
MTEzMTUwNjUxWjAtMSswKQYDVQQDEyJleGFtcGxlLmNvbSBJbnRlcm1lZGlhdGUg
QXV0aG9yaXR5MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAwRyC6TWX
FjF9G3/jvYaJ/AsUo4sT44tqFk83Po05rxIyMisdxsq2D+cMhN4Mp4oIKY4syG5p
CF6vzdqLucZ9KeajaYJ5BOZWq0QA/YFEmqDvXacOLq7cnARcwcagnQ4WqUMPXpbS
ljhIyTQYw1nlC5wUIsDdTlNG3kDpg1yfBuIGZqzKiWx0Bm3Ey8YZPBAzXx/IMv26
lEDF2iBHwwHCh8PsWNo62JBtuZsEIh3Ox7ohxzfrJqEaEfUhW4eu5UGuSuW96ity
80dhU4F+f/pbQhIZazy/ys0XTIQVCCeorGe2ourvUM18PwpXb/RN7PhJonIO/lY4
nN38o4yqjKpZawIDAQABo4HUMIHRMA4GA1UdDwEB/wQEAwIBBjAPBgNVHRMBAf8E
BTADAQH/MB0GA1UdDgQWBBRuY+auU+Iu7gbbCG121PGeEOBy5zAfBgNVHSMEGDAW
gBTkViyLeiMEcTjaSxhVPotDZ+GuKDA7BggrBgEFBQcBAQQvMC0wKwYIKwYBBQUH
MAKGH2h0dHA6Ly8xMjcuMC4wLjE6ODIwMC92MS9wa2kvY2EwMQYDVR0fBCowKDAm
oCSgIoYgaHR0cDovLzEyNy4wLjAuMTo4MjAwL3YxL3BraS9jcmwwDQYJKoZIhvcN
AQELBQADggEBAFBbJNu33XAdgbisJYycCWBb7z1n6qNkMKKzWx89W1l7w1fDNIxp
IaAaYMRS1NyBUNCw6gktCcsQnWpygjZWXYp6nrjj0CncdeEphsHu/ETkPDwf/BW2
t4ffaYwrPZCilPgBVjhCje0ULtbKq+a3F4Lx8VA/fVhdR3Bn0+pXieiQD9G5H3rt
FJRhaqaZFKN+B9/qoToRDLA3ilj+iRHhe6S6s5ndVzxtADerLoPjB7Zwlpta8ucu
QYNxC0Sb3emJAZL5dIsaomU+HLmxAVojqqbZyyHjcUreOszlRDL4iNB60qiFwejm
5nmeR1uf1L5niKyrAND/HFYZoeHrTObbaH8=
-----END CERTIFICATE-----
private_key         -----BEGIN RSA PRIVATE KEY-----
MIIEogIBAAKCAQEAsxuffinnWKV2ectK3TuWgB8ZijyYSzlgtLbfomy+MmNzykMS
2eZMLY4JzGDD57/AzIzQSyn+eHs+9LOizZEhH7C+7EUQolXE/ZXnD64YiIKoN11H
KqXI458uBES6Sz+Dkg9ZXMbw3OwrpaU6lFehENMbAQwqyWF0YAObqKRqtKBkLP62
L1dPPON/DmvGGisn4zj9BrbKEO5478GWKYr3pRF994FoMk1LxLtaMVkT2GZka8X6
FqzMOgPBAIatVg1v0983HbBZCwrV0eaypu25+az1eaub21K6pkVAS2dOoVDcoj+/
tfIb8SJTtYUWIjlfQhI7sBgxtjMBTogcZCUDuQIDAQABAoIBAFwvNHjYEnWCvCbV
plOVrtGEsD2BEJVvE8IPeaz8sSv4GgmZWiOCr+SmfY6Oo2YtQItHUpHNLGdQb8e8
iWeqcdUAwFOU/InBAWHPfJyKa6AfN3s/bDicGXhmXmXeBdBjAVH0ynbBAgmDGLfq
AeuF6qVhMj3oyEDcAuzEDqLO9Qi/xA/7WITcdpBQqpVxkZd9AY89xqcb0mLa7w/p
ZZzCa32DL4QLO3jGwL03z91EA/sM5SWum5A7o5vo14/D60PFHSz6yE2gnGayqJzf
71RAdbLolAX+lzg1WBzx4zcSHvj+pUP23eBblqAKwFoVEAItLzVjPDndXMnMNlo1
UlQDQbECgYEAzTB0/rZ9vyyuswJNdsTIgnkFIRfdPF324kTNI0IC5P21a290nRS1
L/aQ5r4KC1ermQrDnRgFhhB97quS9bEpWDL51Xv1cPCUuxo9srmrHCiVu3/VW5gk
S7O6yTo20309dWtNyf/6g8Ggp+G9zVu272ViT/c6BSvRNWmK7oaTF4UCgYEA33XK
p+eOsnXdgu/wBYKsuAmZ9f0NvhG0M88GKo9+W0FIrl0xuEVaiAvhDX45KJU+sp4k
6JqhYscjHfyN0EBhhB58l3IL00Knl8W/5zTeTKUMCFQ1IA3mK/Xu8NM77POY5GXq
UYTOhTzM5wqd4hK0ykNqK0SV12xvG3Oa3myS36UCgYA4TlPMkcdv7pMCDF+1d8qO
AyelLSdIqYBWFwsz4alprTVbhfo6ILSXtNGOgBfBhQ1RseJ7+VuKrnvgQrTRNwxh
Z5unOZzgoSQvM8Q6hzitQXXVPf8OY3GSVH+tOIxS/MsgrZFrHRNhlIDBkPDEqaZJ
i0ivKOiDAsMmJRA65DL5AQKBgDeydWu6VJ/4rtinE21cL87DXeOpSlaYtRDAximv
kHAQapxDUFQ8vR7xzwt87aRG5tTAhDSR7i3fssoTnAlPMr8qliVtYLMshvdWa8mm
LM5vyPr+eiteK4PDjeXq0KHz6aTsHiZpcsxU5kGkLMwfm35apUjZlHuYZG00OGK+
LzGdAoGAEu7aDoW7GebRn81ebU0iK61zMKYDeW0xOemaXDGDiFeMYXKxnkuI/Mbr
o89mT79kpJUTC/09bBFbjDJVpGY8ejBNF5ZkcS0TMrQKe8kGSAuQuBtvDieYf0XX
6wI+vexrgF8D3aObX83gLs6Wtz+aGNFbiXCHO8/XzWGAxOp2RTM=
-----END RSA PRIVATE KEY-----
private_key_type    rsa
serial_number       60:4e:70:22:75:71:85:ef:3d:bd:a9:23:6c:64:af:60:6c:fa:2d:37
root@master:~#
```

5. Установите корневой сертификат созданного центра сертификации в доверенные в хостовой системе.

```shell
root@master:~# vault write -format=json pki_int/issue/example-dot-com common_name="test.example.com" ttl="720" > cert.json
jq -r '.data.private_key' ./cert.json > ./ssl/test.example.com.key
jq -r '.data.certificate' ./cert.json > ./ssl/test.example.com.crt
```

6. Установите nginx.

```shell
root@master:~# sudo apt-get install nginx -y
```
```shell
root@master:~# systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2022-01-14 15:26:12 UTC; 21h ago
       Docs: man:nginx(8)
   Main PID: 15616 (nginx)
      Tasks: 3 (limit: 1071)
     Memory: 4.4M
     CGroup: /system.slice/nginx.service
             ├─15616 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
             ├─15617 nginx: worker process
             └─15618 nginx: worker process

Jan 14 15:26:12 master systemd[1]: Starting A high performance web server and a reverse proxy server...
Jan 14 15:26:12 master systemd[1]: Started A high performance web server and a reverse proxy server
```
7. По инструкции ([ссылка](https://nginx.org/en/docs/http/configuring_https_servers.html)) настройте nginx на https, используя ранее подготовленный сертификат:
  - можно использовать стандартную стартовую страницу nginx для демонстрации работы сервера;
  - можно использовать и другой html файл, сделанный вами;

```shell
root@master:~# cat /etc/nginx/sites-available/default
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        # SSL configuration
        **listen 443 ssl default_server;
        listen [::]:443 ssl default_server;**
        #

        root /var/www/html;

        # Add index.php to the list if you are using PHP
        index index.html index.htm index.nginx-debian.html;

        **server_name test.example.com;
        ssl_certificate     /home/vagrant/ssl/test.example.com.crt;
        ssl_certificate_key /home/vagrant/ssl/test.example.com.key;
        ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
        ssl_ciphers         HIGH:!aNULL:!MD5;**

```


8. Откройте в браузере на хосте https адрес страницы, которую обслуживает сервер nginx.

![title](images/nginx.png)

9. Создайте скрипт, который будет генерировать новый сертификат в vault:
  - генерируем новый сертификат так, чтобы не переписывать конфиг nginx;
  - перезапускаем nginx для применения нового сертификата.

```shell
#!/usr/bin/env bash
vault write -format=json pki_int/issue/example-dot-com common_name="test.example.com" ttl="720" > cert.json
jq -r '.data.private_key' ./cert.json > ./ssl/test.example.com.key
jq -r '.data.certificate' ./cert.json > ./ssl/test.example.com.crt
sudo service nginx restart
```


10. Поместите скрипт в crontab, чтобы сертификат обновлялся какого-то числа каждого месяца в удобное для вас время.

```shell
root@master:~$ crontab -l
# Edit this file to introduce tasks to be run by cron.
# m h  dom mon dow   command
16 10 * * * /home/vagrant/new_cert.sh >/dev/null 2>&1
vagrant@vagrant:~$ grep CRON /var/log/syslog
...
Dec 27 10:16:01 vagrant CRON[1813]: (vagrant) CMD (/home/vagrant/new_cert.sh >/dev/null 2>&1)
```