## 查看本地镜像和检索拉取Zookeeper 镜像

```bash
docker pull zookeeper:latest
docker pull zookeeper:3.8.2
```

## 创建ZooKeeper 挂载目录（数据挂载目录、配置挂载目录和日志挂载目录）

```bash
mkdir -p ./data/zookeeper/data # 数据挂载目录
mkdir -p ./data/zookeeper/conf # 配置挂载目录
mkdir -p ./data/zookeeper/logs # 日志挂载目录
```

## 启动ZooKeeper容器

```bash
docker run -d --name zookeeper --privileged=true -p 2181:2181  -v ./data/zookeeper/data:/data -v 
./data/zookeeper/conf:/conf -v ./data/zookeeper/logs:/datalog zookeeper:3.5.7
```

> 参数说明

```bash
-e TZ="Asia/Shanghai" # 指定上海时区 
-d # 表示在一直在后台运行容器
-p 2181:2181 # 对端口进行映射，将本地2181端口映射到容器内部的2181端口
--name # 设置创建的容器名称
-v # 将本地目录(文件)挂载到容器指定目录；
--restart always #始终重新启动zookeeper，看需求设置不设置自启动

```

## 添加ZooKeeper配置文件，在挂载配置文件目录(/mydata/zookeeper/conf)下，新增zoo.cfg 配置文件，配置内容如下：

```bash
dataDir=/data  # 保存zookeeper中的数据
clientPort=2181 # 客户端连接端口，通常不做修改
dataLogDir=/datalog
tickTime=2000  # 通信心跳时间
initLimit=5    # LF(leader - follower)初始通信时限
syncLimit=2    # LF 同步通信时限
autopurge.snapRetainCount=3
autopurge.purgeInterval=0
maxClientCnxns=60
standaloneEnabled=true
admin.enableServer=true
server.1=localhost:2888:3888;2181

```

### 进入zookeeper 容器内部

```bash 
docker exec -it zookeeper /bin/bash

```

### 检查容器状态

```bash 
docker exec -it zookeeper /bin/bash ./bin/zkServer.sh status
```

### 进入控制台

```bash 
docker exec -it zookeeper zkCli.sh
```
