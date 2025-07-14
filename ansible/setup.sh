#!/bin/bash

echo "=== Ansible Docker 환경 설정 시작 ==="

# 필요한 디렉토리 생성
mkdir -p ansible
mkdir -p ssh-keys

# SSH 키 생성 (이미 존재하지 않는 경우)
if [ ! -f ssh-keys/id_rsa ]; then
    echo "SSH 키 생성 중..."
    ssh-keygen -t rsa -b 4096 -f ssh-keys/id_rsa -N ""
    cp ssh-keys/id_rsa.pub ssh-keys/authorized_keys
    chmod 600 ssh-keys/id_rsa
    chmod 644 ssh-keys/id_rsa.pub
    chmod 644 ssh-keys/authorized_keys
fi

# Ansible 설정 파일 생성
cat > ansible/ansible.cfg << EOF
[defaults]
host_key_checking = False
inventory = inventory
remote_user = root
private_key_file = /root/.ssh/id_rsa
timeout = 30

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
EOF

# 샘플 playbook 생성
cat > ansible/test-playbook.yml << EOF
---
- name: Test Ansible Connection
  hosts: clients
  gather_facts: yes
  tasks:
    - name: Ping test
      ping:

    - name: Get hostname
      command: hostname
      register: hostname_result

    - name: Display hostname
      debug:
        msg: "Hostname: {{ hostname_result.stdout }}"

    - name: Install basic packages
      apt:
        name:
          - curl
          - wget
          - htop
        state: present
        update_cache: yes
EOF

echo "=== 설정 완료 ==="
echo "다음 명령어로 환경을 시작하세요:"
echo "docker-compose up -d"
echo ""
echo "Ansible 서버에 접속하려면:"
echo "docker exec -it ansible-server bash"
echo ""
echo "테스트 명령어:"
echo "ansible all -m ping"
echo "ansible-playbook test-playbook.yml"