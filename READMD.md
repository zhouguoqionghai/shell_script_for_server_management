#### 少量服务器管理的 `shell` 脚本
将管理脚本加入到 `~/.bashrc` 当中，只有在第一次启动 `msys2` 终端时，需要输入密钥对应的密码，之后密钥交给 ssh-agent 来管理，登陆服务器不再需要密码。
直接使用 shell 函数启动 ssh 登陆，无需记住 `IP`.

![案例](https://github.com/zhouguoqionghai/shell_script_for_server_management/blob/master/example.png)

使用 `sv5` 登陆对应的服务器。

![login](https://github.com/zhouguoqionghai/shell_script_for_server_management/blob/master/login.png)

#### 用法

1、在 `~/.bashrc` 里添加：

`source ~/servers.sh`

2、在 `servers.sh` 脚本当中的 `done << EOF` 与 `EOF` 语句块中的 `here` 文档中添加服务器信息。



3、可以指定一台 `bastion` 机器，通过这台机器来跳转登陆其他机器。跳转机的配置在 `servers.sh` 当中指定。

```bash
base_ip="131.131.131.131" #跳转机ip
base_port="22" #跳转机端口
```

4、修改`set_environ.sh` 中的 `ssh-add` 后的私钥文件名。



跳转登陆和传送文件的函数都以 `j` 开头 `jsv3, jsv6, jsftp5` 等，但是实现上 ssh 跳转登陆并没有使用 `-J` 选项，但是 `sftps` 跳转传送使用了 `-J` 选项。

#### 终

脚本执行后，会创建两个临时的辅助脚本文件 `ssh_agent_var.sh` 与 `xxx.sh`.