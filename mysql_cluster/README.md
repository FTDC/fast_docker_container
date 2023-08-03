# MYSQL 一主双从 集群配置

### 拉取mysql镜像

```bash
docker pull mysql:8.0.13
```

### 启动镜像

```
docker run --name mysql -e MYSQL_ROOT_PASSWORD="123456" -d mysql:8.0.13
```

### 重新启动镜像，并设置master需要配置的参数

```bash
#关掉之前的镜像
docker rm -f mysql
#启动新的镜像，设置server-id和开启logbin
docker run --name mysql -p 3306:3306 -e MYSQL_ROOT_PASSWORD="123456" -d mysql:8.0.13 --server-id=1 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --log-bin=mysql-bin --sync_binlog=1

```

### 进入容器，创建主从同步账号

```bash
#查看容器当前ip网段,后续创建同步账号会需要
docker inspect mysql
docker exec -ti mysql bash
mysql -uroot -p123456
CREATE USER 'sync_root'@'172.17.%.%' IDENTIFIED BY 'sync_123456'
GRANT REPLICATION SLAVE ON *.* TO 'sync_root'@'172.17.%.%'
FLUSH PRIVILEGES
#查看master的binlog信息
SHOW MASTER STATUS

```

### 启动slave容器，实现主从同步

```bash
#启动容器,等待mysql正常启动
docker run --name slave -e MYSQL_ROOT_PASSWORD="123456" -d mysql:8.0.13 --server-id=2 --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
#进入容器，连接master，然后开启同步
docker exec -ti slave bash
mysql -uroot -p123456
# 这里master_host就是刚刚看到的master的ip，master_user就是我们创建用于同步的账号，master_log_file和master_log_pos就是通过show master status获得到的
CHANGE MASTER TO MASTER_HOST='172.17.0.2',MASTER_USER='sync_root',MASTER_PASSWORD='sync_123456',MASTER_LOG_FILE='mysql-bin.000003',MASTER_LOG_POS=900
#开启同步
START SLAVE
#查看slave同步状态
SHOW SLAVE STATUS\G
```

### 测试同步

- 进入master，创建一个测试数据库

```bash
docker exec -ti mysql bash
mysql -uroot -p123456
CREATE DATABASE test

```

- 进入slave，查看对应的test库是否同步过来

```bash
docker exec -ti slave bash
mysql -uroot -p123456
SHOW DATABASES

```

# 基于docker，使用脚本的方式实现主从

### ①重置环境

```bash
docker rm -f mysql-master
docker rm -f mysql-slave
docker network rm mysql
 ```

### ② 准备网络和脚本

1. 编写master用于创建同步账号的脚本 `./init/master/create_sync_user.sh`
2. 创建网卡，保证master和slave都在同一个网段
   ```bash
    docker network create --driver=bridge --subnet=10.10.0.0/16 mysql
    
   ```

   ```bash
   docker run --name mysql-master -v ${PWD}/init/master:/docker-entrypoint-initdb.d -e MYSQL_ROOT_PASSWORD="123456" -e
   MASTER_SYNC_USER="sync_root" -e MASTER_SYNC_PASSWORD="sync_123456" -e ADMIN_USER="root" -e ADMIN_PASSWORD="123456" -e
   ALLOW_HOST="10.10.%.%" -e TZ="Asia/Shanghai" --ip 10.10.10.10 --network mysql -d mysql:8.0.13 --server-id=1
   --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci --log-bin=mysql-bin --sync_binlog=1
   ```
3. 编写mysql-slave脚本 `./init/slave/slave.sh`

4. 创建nginx负责均衡的配置文件
   > 这里使用tcp代理，需要开启nginx的stream支持
   ```bash
   user  nginx;
   worker_processes  auto;
   
   error_log  /var/log/nginx/error.log warn;
   pid        /var/run/nginx.pid;
   
   events {
       worker_connections  1024;
   }
   # 添加stream模块，实现tcp反向代理
   stream {
       include /opt/nginx/stream/conf.d/*.conf; #加载 /opt/nginx/stream/conf.d目录下面的所有配置文件
   }
   
   ```


