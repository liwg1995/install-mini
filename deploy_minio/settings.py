#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time : 2020/8/31 13:53
# @Author : olei.me
# @Site : https://olei.me
# @File : settings.py
# @Software: PyCharm

from fabric.api import *

env.roledefs = {
    'all': ["192.168.0.170"],
    'distribute_servers': ["192.168.0.170"],
    'nginx_servers': ["192.168.0.170"],
    'client_servers': ["192.168.0.170"]
}
# env.user = 'root'
env.passwords = {
    'root@192.168.0.170:22': '123456',
}

minio_binary_file_source = '/usr/local/bin/'
minio_conf_file_source = '/etc/default/'
minio_nginx_lvs_file_source = '/etc/nginx/conf.d/'
minio_systemd_conf_source = '/usr/lib/systemd/system/'

