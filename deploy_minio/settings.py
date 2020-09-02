#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time : 2020/8/31 13:53
# @Author : olei.me
# @Site : https://olei.me
# @File : settings.py
# @Software: PyCharm

from fabric.api import *

env.roledefs = {
    'all': ["192.168.2.170", "192.168.2.171", "192.168.2.172", "192.168.2.173","192.168.2.174"],
    'distribute_servers': ["192.168.2.170", "192.168.2.171", "192.168.2.172", "192.168.2.173"],
    'nginx_servers': ["192.168.2.174"],
    'client_servers': ["192.168.2.170", "192.168.2.171", "192.168.2.172", "192.168.2.173"]
}
# env.user = 'root'
env.passwords = {
    'root@192.168.2.170:22': '123456',
    'root@192.168.2.171:22': '123456',
    'root@192.168.2.172:22': '123456',
    'root@192.168.2.173:22': '123456',
    'root@192.168.2.174:22': '123456'
}

minio_binary_file_source = '/usr/local/bin/'
minio_conf_file_source = '/etc/default/'
minio_nginx_lvs_file_source = '/etc/nginx/conf.d/'
minio_systemd_conf_source = '/usr/lib/systemd/system/'

