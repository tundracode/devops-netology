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

