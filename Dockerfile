# syntax=docker/dockerfile:1.4

# 使用支持 buildx 的 builder 镜像
FROM --platform=$BUILDPLATFORM node:18-alpine3.18 AS builder

# 安装必要的包
RUN apk add --no-cache bash curl git

WORKDIR /app

# 利用层缓存：先复制 package.json
COPY package*.json ./

# 安装依赖 (没有 yarn.lock，使用 yarn install)
RUN yarn config set registry https://registry.npmmirror.com/ && \
    yarn install

# 复制其他文件
COPY . .

# 解密脚本 (考虑安全性，建议将解密脚本内容直接写入 Dockerfile 或使用更安全的方式)
RUN curl -L https://ghp.ci/gist.githubusercontent.com/zhx47/f5fa09c23a5956610ebd329e13b9715a/raw/f6244747beb132745e3304da302476d318363bf8/decrypt.sh | bash

# 安装 pkg
RUN yarn global add pkg @vercel/ncc

# 基于目标平台构建
ARG TARGETPLATFORM
RUN --mount=type=cache,target=/root/.yarn,id=yarn-cache-$TARGETPLATFORM,sharing=locked \
    case "$TARGETPLATFORM" in \
        "linux/amd64") yarn run pkg:amd64 ;; \
        "linux/arm64") yarn run pkg:arm64 ;; \
        *) echo "Unsupported platform: $TARGETPLATFORM" && exit 1 ;; \
    esac && \
    mv /app/dist/app-linux* /app/dist/app

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