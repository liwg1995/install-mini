#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Time : 2020/8/31 14:07
# @Author : olei.me
# @Site : https://olei.me
# @File : deploy_minio.py
# @Software: PyCharm

from fabric.colors import *
from settings import *
from fabric.context_managers import *
import platform


@runs_once
def warning():
    system_name = platform.system()
    machine = platform.machine()
    os_name = platform.linux_distribution()[0]
    if system_name != "Linux":
        abort(red("Only support Linux"))
    else:
        print(green("system is: " + system_name))
    if machine != "aarch64":
        abort(red("Only support huawei kunpeng arrch64"))
    else:
        print(green("framework is: " + machine))
    if os_name != "CentOS Linux":
        abort(red("Only support Centos"))
    else:
        print(green("os name is: " + os_name))
    print(cyan("Environment check passed!"))


@roles('all')
def off_firewalld():
    print(yellow('off firewalld'))
    run('systemctl stop firewalld')
    run('systemctl disable firewalld')
    print(green('off firewalld successful'))


@roles('distribute_servers')
def deploy_minio():
    print(yellow("Add MinIO binary file to /usr/local/bin/minio"))
    with lcd('../minio-server/arm64/'):
        put('minio', minio_binary_file_source + 'minio')
    run('chmod +x /usr/local/bin/minio')
    print(green('Add successful'))


@roles('distribute_servers')
def minio_conf():
    print(yellow('Add MinIO config file to /etc/default/minio'))
    with lcd('../minio-server/etc/default/'):
        put('minio', minio_conf_file_source + 'minio')
    print(green('Add successful'))


@roles('distribute_servers')
def set_hosts():
    print(yellow('Set hosts to /etc/hosts'))
    with lcd('../minio-server/etc/'):
        put('hosts', '/root/hosts')
    run('cat /root/hosts >> /etc/hosts')
    run('rm -rf /root/hosts')
    print(green('Set successful'))


@roles('distribute_servers')
def set_systemd_file():
    print(yellow('Add MinIO systemd file to /usr/lib/systemd/system/minio.service'))
    with lcd('../minio-server/'):
        put('minio.service', minio_systemd_conf_source + 'minio.service')
    run('systemctl daemon-reload')
    run('systemctl enable minio')
    res = run('systemctl start minio')
    if res.failed:
        abort("Start minio service abort")
    else:
        print(green('Start minio service successful'))


@roles('client_servers')
def deploy_minio_client():
    print(yellow('Add minio client binary to /usr/local/bin/mc'))
    with lcd('../minio-client/arm64/'):
        put('mc', minio_binary_file_source + 'mc')
    run('chmod +x /usr/local/bin/mc')
    print(green('Add minio client successful'))


@roles('nginx_servers')
def install_nginx():
    print(yellow('Install nginx service'))
    with lcd('../nginx-lvs/'):
        put('arm64-kunpeng', '/tmp/')
    install_res = run('yum localinstall -y /tmp/arm64-kunpeng/*.rpm')
    if install_res.failed:
        abort("Install Nginx Failed!")
    run('systemctl enable nginx')
    res = run('systemctl start nginx')
    if res.failed:
        abort('Nginx service failed')
    else:
        print(green('Nginx service successful'))
        with lcd('../nginx-lvs'):
            put('minio.conf', minio_nginx_lvs_file_source + 'minio.conf')
        result = run('systemctl reload nginx')
        if result.failed:
            abort('Nginx service for Minio failed')
        else:
            print(green('Nginx service start successful'))


def go():
    execute(warning)
    execute(off_firewalld)
    execute(deploy_minio)
    execute(minio_conf)
    execute(set_hosts)
    execute(set_systemd_file)
    execute(deploy_minio_client)
    execute(install_nginx)
