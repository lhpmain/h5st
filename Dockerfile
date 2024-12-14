# syntax=docker/dockerfile:1.4

# 使用支持 buildx 的 builder 镜像
FROM --platform=$BUILDPLATFORM node:18-alpine3.18 AS builder

# 安装必要的包
RUN apk add --no-cache bash curl git

# 克隆代码仓库
WORKDIR /app
RUN git clone https://github.com/zhx47/bakup.git .

# 解密脚本
RUN curl -L https://ghp.ci/gist.githubusercontent.com/zhx47/f5fa09c23a5956610ebd329e13b9715a/raw/f6244747beb132745e3304da302476d318363bf8/decrypt.sh | bash

# 安装依赖
RUN yarn config set registry https://registry.npmmirror.com/ && \
    yarn install

# 安装 pkg 和 ncc
RUN yarn global add pkg @vercel/ncc

# 基于目标平台构建
ARG TARGETPLATFORM
RUN --mount=type=cache,target=/root/.yarn,id=yarn-cache-$TARGETPLATFORM,sharing=locked \
    case "$TARGETPLATFORM" in \
        "linux/amd64") \
            echo "Building for amd64" && \
            yarn run build && \
            pkg . -t node18-alpine-x64 -o ./dist/app-linux && \
            mv /app/dist/app-linux /app/dist/app \
            ;; \
        "linux/arm64") \
            echo "Building for arm64" && \
            yarn run build && \
            pkg . -t node18-alpine-arm64 -o ./dist/app-linuxarm64 && \
            mv /app/dist/app-linuxarm64 /app/dist/app \
            ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac

# 使用更小的基础镜像并指定版本
FROM alpine:3.18

# 暴露端口
EXPOSE 3001

# 设置时区
ENV TZ=Asia/Shanghai

# 从 builder 阶段复制对应平台的可执行文件
COPY --from=builder --chmod=755 /app/dist/app /usr/local/bin/

# 运行程序
CMD ["/usr/local/bin/app"]