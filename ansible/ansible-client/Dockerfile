# 베이스 이미지로 Ubuntu 최신 버전 사용
FROM ubuntu:22.04

# SSH 서버와 sudo, python3 설치 (Ansible 모듈 실행에 필요)
RUN apt-get update && \
    apt-get install -y openssh-server sudo python3 && \
    rm -rf /var/lib/apt/lists/*

# Ansible 접속용 사용자 생성 (ansible_user)
RUN useradd -m -s /bin/bash ansible_user

# 생성한 사용자가 비밀번호 없이 sudo를 사용할 수 있도록 설정
RUN echo "ansible_user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# SSH 서버 설정을 위해 sshd_run 디렉토리 생성
RUN mkdir -p /var/run/sshd

# Copy id_rsa
# COPY ../.ssh/id_rsa /home/ansible_user/id_rsa.pub

# 사용자 홈 디렉토리에 .ssh 디렉토리 생성 및 권한 설정
# authorized_keys 파일은 docker-compose에서 볼륨 마운트로 주입될 예정
RUN mkdir -p /home/ansible_user/.ssh && \
    chown -R ansible_user:ansible_user /home/ansible_user/.ssh && \
    chmod 700 /home/ansible_user/.ssh 

# Entrypoint 스크립트 복사 및 실행 권한 부여
COPY entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["entrypoint.sh"]

# 컨테이너 실행 시 SSH 서버를 데몬 모드로 실행
CMD ["/usr/sbin/sshd", "-D"]