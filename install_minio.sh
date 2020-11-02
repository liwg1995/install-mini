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

while true; do
  read -r -p "上述内容已经阅读完毕且必要修改项均已经修改准确？[Y/N]" input
  case $input in
  [yY][eE][sS] | [yY])
    echo "即将执行安装脚本..."
    sleep 3s
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
    ;;
  [nN][oO] | [nN])
    echo "请再次确认安装须知"
    exit 1
    ;;
  *)
    echo "Invalid input..."
    ;;
  esac
done
