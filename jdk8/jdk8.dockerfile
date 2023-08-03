# 建立一个新的镜像文件，配置模板：新建立的镜像是以ubuntu:latest（镜像名称）为基础模板
# 因为jdk必须运行在操作系统之上
FROM ubuntu:latest

# 维护者
MAINTAINER author <xxx@gmail.com>

# 创建一个新目录来存储jdk文件
RUN mkdir /usr/local/java

#将jdk压缩文件复制到镜像中，它将自动解压缩tar文件
ADD jre-8u202-linux-x64.tar.gz /usr/local/java/

# 设置时区
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

# 设置环境变量
ENV JAVA_HOME /usr/local/java/jre1.8.0_202
ENV PATH $JAVA_HOME/bin:$PATH

# VOLUME 指定了临时文件目录为/tmp
# 其效果是在主机 /var/lib/docker 目录下创建了一个临时文件，并链接到容器的/tmp
VOLUME /tmp