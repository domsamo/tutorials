# 베이스 이미지로 Ubuntu 최신 버전 사용
FROM ubuntu:22.04

# Ansible과 SSH 클라이언트 설치
RUN apt-get update && \
    apt-get install -y ansible openssh-client && \
    rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /ansible