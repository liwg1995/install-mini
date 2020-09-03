
### 准备  
> 之后引入`jinja2`语法做配置文件渲染  
- 需要修改`deploy_minio`中的`setting.py`中的机器的信息
- 需要修改`minio-server`中的`etc/default`文件中的信息以及`/etc/hosts`文件的信息
- 需要修改`nginx-lvs`中的`minio.conf`的`IP`地址信息
- 每个节点需要挂载的盘，自行挂载，与`minio-server`中的`etc/default`中的配置项相对应即可

### 注意
- 本脚本只支持`centos 7.x  x86_64`下安装

### 安装
- 本脚本所在节点，执行
```
bash install_minio.sh
```

### TODO
- [ ] 引入`jinja2`，渲染配置文件
- [ ] 适配`Ubuntu`下的安装
- [ ] 适配`arm`鲲鹏架构下的安装 for `Centos 7.x`
- [ ] 适配`arm`飞腾架构下的安装 for `银河麒麟 4.0.2 server`

### TIPS
- `shell`脚本还未测试，`python`脚本已经做了测试
