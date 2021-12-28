#!/usr/bin/env python3

import socket as s
import time as t
import datetime as dt
import json
import yaml
import os

i     = 1
wait  = 2 
srv   = {'drive.google.com':'0.0.0.0', 'mail.google.com':'0.0.0.0', 'google.com':'0.0.0.0'}
init  = 0
fpath = "{0}/".format(os.getcwd())
flog  = "{0}/error.log".format(os.getcwd())

while True : 
  for host in srv:
    is_error = False 
    ip = s.gethostbyname(host)
    if ip != srv[host]:
      if init !=1: 
        is_error=True
        with open(flog,'a') as fl:
          print(str(dt.datetime.now().strftime("%Y-%m-%d %H:%M:%S")) +' [ERROR] ' + str(host) +' IP mistmatch: '+srv[host]+' '+ip,file=fl)
        with open(fpath+host+".json",'w') as jsf:
          json_data= json.dumps({host:ip})
          jsf.write(json_data) 
        with open(fpath+host+".yaml",'w') as ymf:
          yaml_data= yaml.dump([{host : ip}])
          ymf.write(yaml_data) 
    if is_error:
      data = []  
      for host in srv:  
        data.append({host:ip})
      with open(fpath+"services_conf.json",'w') as jsf:
        json_data= json.dumps(data)
        jsf.write(json_data)
      with open(fpath+"services_conf.yaml",'w') as ymf:
        yaml_data= yaml.dump(data)
        ymf.write(yaml_data)
      srv[host]=ip
  t.sleep(wait)
