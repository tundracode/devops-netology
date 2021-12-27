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



