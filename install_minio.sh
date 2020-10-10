#!/usr/bin/env bash

echo
echo "*********************************************************************************************************************************"
echo
cat << EOF
## 请阅读如下内容，5s之后执行安装步骤：
  1. 需要修改deploy_minio中的setting.py中的机器的信息
  2. 需要修改minio-server中的etc/default文件中的信息以及/etc/hosts文件的信息
  3. 需要修改nginx-lvs中的minio.conf的IP地址信息
  4. 每个节点需要挂载的盘，自行挂载，与minio-server中的etc/default中的配置项相对应即可
  5. 上述修改完毕没有问题，直接运行 bash install_minio.sh
EOF
echo "*********************************************************************************************************************************"
echo

sleep 5s

# check os is or not linux
echo "******* Check os *******"
os_name=$(uname)
if [ $os_name != 'Linux' ]; then
  echo "os is not Linux!"
  exit 1
fi
if [ ! -f "/etc/redhat-release" ]; then
  echo "os is not Centos!"
  exit 1
fi

kunpeng=$(uname -a | awk -F ' ' '{print $2}')
if [ $kunpeng != 'kunpeng' ]; then
    echo "cpu is not kunpeng!This script just support huawei kunpeng"
    exit 1
fi

echo "check os passed"

# install fabric3
echo "******* Check python3 ******"
which python3 >/dev/null 2>&1

if [ $? != 0 ]; then
  echo "Only running in python3 env!Now install python3"
  echo -n "\n"
  echo "Install python3 lib..."
  yum localinstall ./lib/python3-os-lib/kunpeng/*.rpm -y
  if [ $? != 0 ]; then
    echo "python3 os lib install failed!"
    exit 1
  fi
  tar -zxvf ./python-packages/kunpeng/python3.7/python3.tgz -C /usr/local/
  ln -s /usr/local/python3/bin/python3 /usr/local/bin/python3
  ln -s /usr/local/python3/bin/pip3 /usr/local/bin/pip3
  python_version=$(python3 --version)
  echo "Install python3 and pip3 successful! Then version is: $python_version"
fi

which fab >/dev/null 2>&1
if [ $? != 0 ]; then
  if [ -f '/usr/local/python3/bin/fab' ]; then
    ln -s /usr/local/python3/bin/fab /usr/local/bin/fab
  fi
fi
echo "Install fabric3 successful! "

echo "Install minio..."
cd deploy_minio/ || exit 1
fab -f deploy_minio.py go