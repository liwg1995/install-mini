#!/usr/bin/env bash

echo
echo "*********************************************************************************************************************************"
echo
cat <<EOF
## 请阅读如下内容：
  1. 需要修改deploy_minio中的setting.py中的机器的信息
  2. 需要修改minio-server中的etc/default文件中的信息以及/etc/hosts文件的信息
  3. 需要修改nginx-lvs中的minio.conf的IP地址信息
  4. 每个节点需要挂载的盘，自行挂载，与minio-server中的etc/default中的配置项相对应即可
  5. 上述修改完毕没有问题，直接运行 bash install_minio.sh
  6. 确保系统纯净，安装过程不支持CTRL+C操作
EOF
echo "*********************************************************************************************************************************"
echo

#!/bin/bash

while true; do
  read -r -p "上述内容已经阅读完毕且必要修改项均已经修改准确？ [Y/n] " input

  case $input in
  [yY][eE][sS] | [yY])
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

    echo "check os passed"

    # install fabric3
    echo "******* Check python3 ******"
    which python3 >/dev/null 2>&1

    if [ $? != 0 ]; then
      echo "Only running in python3 env!Now install python3"
      echo -n "\n"
      echo "Install python3 lib..."
      yum localinstall ./lib/python3-os-lib/*.rpm -y
      if [ $? != 0 ]; then
        echo "python3 os lib install failed!"
        exit 1
      fi

      if [ ! -d "/usr/local/python3" ]; then
        mkdir /usr/local/python3
      fi

      tar -zxvf ./lib/python3/Python-3.7.2.tgz -C /tmp && cd /tmp/Python-3.7.2/ || exit 1
      echo "*** Install Python3 ***"
      ./configure --prefix=/usr/local/python3 --enable-optimizations --with-ssl
      if [ $? != 0 ]; then
        echo "configure failed! Please check your os env"
        exit 1
      fi
      echo "Please wait a moment..."
      make
      if [ $? != 0 ]; then
        echo "make failed! Please check your os env"
        exit 1
      fi
      make install
      if [ $? != 0 ]; then
        echo "make install failed! Please check your os env"
        exit 1
      fi
      ln -s /usr/local/python3/bin/python3 /usr/local/bin/python3
      ln -s /usr/local/python3/bin/pip3 /usr/local/bin/pip3
      python_version=$(python3 --version)
      echo "Install python3 and pip3 successful! Then version is: $python_version"
      cd - || exit 1
    fi

    ping -c 1 www.baidu.com 1>/dev/null 2>&1
    if [ $? == 0 ]; then
      echo "Operating system networking detected! Install fabric3 from networking"
      which pip3 >/dev/null 2>&1
      if [ $? != 0 ]; then
        yum install python3-pip -y
      fi
      pip3 install fabric3 -i https://pypi.douban.com/simple
    else
      echo "The operating system is not networked! Install fabric3 from local"
      python3_ver=$(python3 --version | awk -F ' ' '{print $2}' | awk -F '.' '{print $1$2}')
      if [ $python3_ver == '36' ]; then
        pip3 install ./python-packages/python3.6/*.whl
      elif [ $python3_ver == '37' ]; then
        pip3 install ./python-packages/python3.7/*.whl
      fi

      if [ $? != 0 ]; then
        echo "Install fabric3 failed! Please check your os env."
        exit 1
      fi
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
    ;;

  [nN][oO] | [nN])
    echo "请再次确认安装须知！"
    exit 1
    ;;

  *)
    echo "Invalid input..."
    ;;
  esac
done
