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




