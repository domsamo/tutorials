# Ansible Docker 환경 구성

- 격리된 환경: 로컬 머신에 아무것도 설치할 필요 없이 Docker 컨테이너 안에서 모든 테스트가 이루어집니다.
- 일관성: docker-compose.yml 파일 하나로 어디서든 동일한 환경을 재현할 수 있습니다.
- 쉬운 관리: docker-compose up, down 명령어로 전체 테스트 환경을 쉽게 생성하고 삭제할 수 있습니다.
 
 
## 1. 프로젝트 폴더 구조 생성
```text
    ansible-docker-test/
    ├── .ssh/
    │   ├── id_rsa          # Ansible 서버가 사용할 SSH 비공개 키
    │   └── id_rsa.pub      # Ansible 클라이언트에게 등록할 SSH 공개 키
    ├── ansible-client/
    │   └── Dockerfile
    │   └── entrypoint.sh
    ├── ansible-server/
    │   ├── Dockerfile
    │   ├── hosts.ini       # Ansible 인벤토리 파일
    │   └── playbook.yml    # 테스트용 플레이북
    └── docker-compose.yml
``` 

## 2. SSH 키 생성
ansible-server가 ansible-client에 비밀번호 없이 접속하기 위해 SSH 키를 생성합니다.
```shell
# PowerShell 에서 실행 

# .ssh 폴더 생성
mkdir .ssh

cd .ssh

# SSH 키 생성 (-N ""는 passphrase를 비워두는 옵션)
ssh-keygen -t rsa -b 4096 -f id_rsa -N ""
```

## 3. Ansible Client 구성 (ansible-client/Dockerfile)
- ansible-client/Dockerfile 파일 작성:
```dockerfile
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
``` 

## 4. Ansible Server 구성 (ansible-server/)
ansible-server/Dockerfile 파일 작성:
```dockerfile
# 베이스 이미지로 Ubuntu 최신 버전 사용
FROM ubuntu:22.04

# Ansible과 SSH 클라이언트 설치
RUN apt-get update && \
    apt-get install -y ansible openssh-client && \
    rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /ansible
```

**ansible-server/hosts.ini (인벤토리 파일) 작성:**

ansible-client는 docker-compose 내부 네트워크에서 사용할 서비스 이름입니다. Docker가 자동으로 DNS를 설정해줍니다.

```ini
[clients]
ansible-client ansible_user=ansible_user ansible_ssh_private_key_file=/root/.ssh/id_rsa ansible_python_interpreter=/usr/bin/python3

[all:vars]
# 호스트 키 체크를 비활성화하여 처음 접속 시 확인 프롬프트를 건너뜀
ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```


**ansible-server/playbook.yml (테스트 플레이북) 작성:**

간단하게 ping 테스트를 하고, ansible-client에 htop 패키지를 설치하는 예제입니다.

```yaml
---
- name: Test connectivity and setup client
  hosts: clients
  become: yes  # sudo 권한으로 실행

  tasks:
    - name: Ping all clients
      ansible.builtin.ping:

    - name: Ensure htop is installed
      ansible.builtin.apt:
        name: htop
        state: present
        update_cache: yes
```

## 5. Docker Compose 파일 작성
 
이제 두 서비스를 하나로 묶어줄 docker-compose.yml 파일을 작성합니다.
```dockerfile
version: '3.8'

services:
  ansible-server:
    build:
      context: ./ansible-server
    container_name: ansible-server
    # tty: true를 설정하여 컨테이너가 바로 종료되지 않도록 함
    tty: true
    volumes:
      # 로컬의 ansible-server 폴더를 컨테이너의 /ansible과 동기화
      - ./ansible-server:/ansible
      # 로컬의 SSH 비공개 키를 컨테이너의 root 사용자가 접근할 수 있는 위치에 마운트 (읽기 전용)
      - ./.ssh/id_rsa:/root/.ssh/id_rsa:ro
    # ansible-client가 먼저 실행되도록 의존성 설정
    depends_on:
      - ansible-client

  ansible-client:
    build:
      context: ./ansible-client
    container_name: ansible-client
    volumes:
      # 로컬의 SSH 공개 키를 클라이언트의 authorized_keys 파일로 마운트 (읽기 전용)
       - ./.ssh/id_rsa.pub:/home/ansible_user/id_rsa.pub:ro
    #  - ./.ssh/id_rsa.pub:/home/ansible_user/.ssh/authorized_keys:ro
    # (선택 사항) 로컬 PC에서 클라이언트로 직접 SSH 접속하여 디버깅하고 싶을 때 포트 개방
    # ports:
    #   - "2222:22"
``` 

## 6. 실행 및 테스트
모든 파일 작성이 완료되었습니다. 이제 Docker 컨테이너를 빌드하고 실행하여 Ansible을 테스트합니다.

### 1. Docker 컨테이너 빌드 및 실행 **
프로젝트 루트 폴더(ansible-docker-test)에서 다음 명령어를 실행합니다.

```bash
# 컨테이너 이미지 빌드
docker-compose build

# 백그라운드에서 컨테이너 실행
docker-compose up -d

```

### 2. ansible-server 컨테이너 접속
아래 명령어로 실행 중인 ansible-server 컨테이너 내부에 셸(bash)로 접속합니다.
```bash
docker-compose exec ansible-server bash
```

### 3. Ansible 명령어 테스트
이제 컨테이너 안에서 Ansible 명령어를 실행하여 ansible-client와의 연결을 테스트합니다.

**Ping 테스트:**
```bash
# 컨테이너 내부에서 실행
ansible all -i hosts.ini -m ping
```

성공하면 다음과 같은 초록색 SUCCESS 메시지가 나타납니다.
```json
ansible-client | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3"
    },
    "changed": false,
    "ping": "pong"
}
```

**플레이북 실행:**

```bash
# 컨테이너 내부에서 실행
ansible-playbook -i hosts.ini playbook.yml
```

성공적으로 실행되면 htop 패키지가 ansible-client에 설치되고, changed=1과 같은 결과가 표시됩니다.


### 4. (선택) 결과 확인
플레이북이 잘 실행되었는지 ansible-client에 직접 들어가서 확인할 수 있습니다.
```bash
# 새 터미널에서 실행
docker compose exec ansible-client bash

# 컨테이너 내부에서 htop이 설치되었는지 확인
which htop
```
/usr/bin/htop 경로가 출력되면 성공입니다.


### 7. 환경 종료 및 정리
테스트가 끝나면 다음 명령어로 모든 컨테이너와 네트워크를 깔끔하게 삭제할 수 있습니다.

```bash
docker compose down -v
```

** 참고 **

Dockerfile 수정 시 재 build 방법 
```bash
docker compose up -d --build

docker compose build --no-cache
```

