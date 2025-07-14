# Ansible Docker 환경 구성

이 프로젝트는 Docker Compose를 사용하여 Ansible 서버와 클라이언트 환경을 구성합니다.

## 구성 요소

- **ansible-server**: Ansible이 설치된 제어 노드
- **ansible-client1, ansible-client2**: SSH 서버가 실행되는 관리 대상 노드

## 사용 방법

### 1. 초기 설정

```bash
# 설정 스크립트 실행
chmod +x setup.sh
./setup.sh
```

### 2. 환경 시작

```bash
# Docker Compose로 모든 컨테이너 시작
docker-compose up -d

# 컨테이너 상태 확인
docker-compose ps
```

### 3. Ansible 서버 접속

```bash
# Ansible 서버 컨테이너에 접속
docker exec -it ansible-server bash
```

### 4. 연결 테스트

```bash
# 모든 클라이언트에 ping 테스트
ansible all -m ping

# 특정 호스트에 명령 실행
ansible ansible-client1 -m command -a "hostname"

# 샘플 playbook 실행
ansible-playbook test-playbook.yml
```

## 주요 파일 구조

```
.
├── docker-compose.yml
├── Dockerfile.ansible-server
├── Dockerfile.ansible-client
├── setup.sh
├── ansible/
│   ├── inventory
│   ├── ansible.cfg
│   └── test-playbook.yml
└── ssh-keys/
    ├── id_rsa
    ├── id_rsa.pub
    └── authorized_keys
```

## 사용 가능한 명령어

### Ansible Ad-hoc 명령어
```bash
# 시스템 정보 확인
ansible all -m setup

# 패키지 설치
ansible all -m apt -a "name=htop state=present" --become

# 서비스 상태 확인
ansible all -m service -a "name=ssh state=started"

# 파일 복사
ansible all -m copy -a "src=/etc/hosts dest=/tmp/hosts"
```

### Playbook 예제
```bash
# 기본 playbook 실행
ansible-playbook test-playbook.yml

# 특정 호스트에만 실행
ansible-playbook test-playbook.yml --limit ansible-client1

# 디버그 모드로 실행
ansible-playbook test-playbook.yml -vvv
```

## 환경 정리

```bash
# 모든 컨테이너 중지 및 제거
docker-compose down

# 볼륨과 네트워크까지 모두 제거
docker-compose down -v --remove-orphans
```

## 문제 해결

### SSH 연결 문제
- SSH 키가 올바르게 생성되었는지 확인
- 클라이언트 컨테이너에서 SSH 서비스가 실행 중인지 확인

### 권한 문제
- SSH 키 파일 권한 확인 (private key: 600, public key: 644)
- authorized_keys 파일 권한 확인 (644)

### 네트워크 문제
- Docker 네트워크 상태 확인: `docker network ls`
- 컨테이너 간 연결 테스트: `docker exec -it ansible-server ping ansible-client1`