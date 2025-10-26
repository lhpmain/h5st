# h5st Docker 镜像

此仓库提供 h5st 的 Docker 镜像。

## 使用方法

1.  **拉取镜像：**

    ```bash
    docker pull lhpmain/h5st:latest
    ```

2.  **运行容器：**

    ```bash
    docker run -d -p 8080:3001 lhpmain/h5st:latest
    ```

    或使用Docker-Compose方式

    ```yaml
    services:
    h5st:
        container_name: h5st
        image: lhpmain/h5st:latest
        ports:
            - 3001:3001
        restart: on-failure:5
        network_mode: bridge
    ```

    此命令将在后台运行容器 (`-d`)，并将主机上的端口 8080 映射到容器内的端口 3001。根据需要调整端口映射。
    支持Amd64和arm64架构

3.  **使用：**

    在你需要的地方填写 `http://localhost:3001` 或 `http://127.0.0.1:3001/h5st`（或者你更改端口映射后的相应端口）。

## 自动构建

当上游仓库有更新时，Docker 镜像将自动构建并发布到 Docker Hub。

## 鸣谢

https://github.com/zhx47/bakup
