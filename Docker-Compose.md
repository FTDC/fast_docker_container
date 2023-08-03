## 安装下载Docker Compose:
```
curl -L https://get.daocloud.io/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
```
### 修改该文件的权限为可执行和查看版本：
```
chmod +x /usr/local/bin/docker-compose

ln -s /usr/local/bin/docker-compose \
    /usr/bin/docker-compose

docker-compose -v
```

### 使用Docker Compose的步骤
>使用Dockerfile定义应用程序环境，一般需要修改初始镜像行为时才需要使用；
>使用docker-compose.yml定义需要部署的应用程序服务，以便执行脚本一次性部署；
>使用docker-compose up命令将所有应用服务一次性部署起来。

## docker-compose.yml常用命令

1. ### docker-compose ps 命令
   > 如果你的编排文件的文件名不是 docker-compose.yml，那么你就需要使用 `-f` 选项给指定
    ```bash
    docker-compose -f xxx.yml ps
    ```
2. ### docker-compose up 命令

   > -d 表示在后台运行
    ```bash
    docker-compose up
   
    # 上面的命令省略掉了 -f docker-compose.yml
    # docker-compose -f docker-compose.yml up
   
   docker-compose up rabbitmq
   # 使用场景：比如要暴露一个端口，可以 remove 之后，再使用 up xxx服务 进行端口的暴露
   # 注意：这里 up 后面跟的不是容器名，而是 服务名（services 下面的名称，如果你得取名不一致的话，就会有区别）
   # 指定 up 其中的一个服务
    ```
3. ### docker-compose down 命令
   > 此命令停止用 up 命令所启动的容器并移除网络

4. ### docker-compose restart 命令
   > 重启项目中的服务。用法跟上面的 stop，start 一样。

5. ### docker-compose logs 命令
   > -f 参数：持续的输出日志
   > -t 参数：显示时间戳
   > 
   > 查看服务容器的输出。默认情况下，docker-compose 将对不同的服务输出使用不同的颜色来区分。
   > 可以通过 `--no-color` 来关闭颜色。该命令在调试问题的时候十分有用

   ```bash
     docker-compose -f xxx.yml logs 查看整体的日志 
     docker-compose -f xxx.yml logs elasticsearch 查看单独容器的日志
   ```

