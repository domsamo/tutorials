#!/usr/bin/env pwsh

Write-Host "=== Ansible Docker 환경 설정 시작 ===" -ForegroundColor Green

# 필요한 디렉토리 생성
Write-Host "디렉토리 생성 중..." -ForegroundColor Yellow
if (-not (Test-Path "ansible")) {
    New-Item -ItemType Directory -Path "ansible"
}
if (-not (Test-Path "ssh-keys")) {
    New-Item -ItemType Directory -Path "ssh-keys"
}

# SSH 키 생성 (이미 존재하지 않는 경우)
if (-not (Test-Path "ssh-keys\id_rsa")) {
    Write-Host "SSH 키 생성 중..." -ForegroundColor Yellow

    # Docker를 사용하여 SSH 키 생성 (Windows에서 ssh-keygen이 없을 수 있음)
    docker run --rm -v "${PWD}\ssh-keys:/tmp/ssh-keys" alpine:latest sh -c "
        apk add --no-cache openssh-client &&
        ssh-keygen -t rsa -b 4096 -f /tmp/ssh-keys/id_rsa -N '' &&
        cp /tmp/ssh-keys/id_rsa.pub /tmp/ssh-keys/authorized_keys
    "

    Write-Host "SSH 키 생성 완료" -ForegroundColor Green
} else {
    Write-Host "SSH 키가 이미 존재합니다." -ForegroundColor Cyan
}

# Ansible 설정 파일 생성
Write-Host "Ansible 설정 파일 생성 중..." -ForegroundColor Yellow
@"
[defaults]
host_key_checking = False
inventory = inventory
remote_user = root
private_key_file = /root/.ssh/id_rsa
timeout = 30

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
"@ | Out-File -FilePath "ansible\ansible.cfg" -Encoding UTF8

# 샘플 playbook 생성
Write-Host "샘플 playbook 생성 중..." -ForegroundColor Yellow
@"
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
"@ | Out-File -FilePath "ansible\test-playbook.yml" -Encoding UTF8

# 추가 유용한 playbook들 생성
Write-Host "추가 playbook 생성 중..." -ForegroundColor Yellow

# 시스템 정보 수집 playbook
@"
---
- name: System Information Gathering
  hosts: clients
  gather_facts: yes
  tasks:
    - name: Display system information
      debug:
        msg: |
          OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
          Kernel: {{ ansible_kernel }}
          Architecture: {{ ansible_architecture }}
          Memory: {{ ansible_memtotal_mb }} MB
          CPU: {{ ansible_processor_cores }} cores

    - name: Check disk usage
      command: df -h
      register: disk_usage

    - name: Display disk usage
      debug:
        var: disk_usage.stdout_lines
"@ | Out-File -FilePath "ansible\system-info.yml" -Encoding UTF8

# 패키지 관리 playbook
@"
---
- name: Package Management
  hosts: clients
  become: yes
  tasks:
    - name: Update package cache
      apt:
        update_cache: yes

    - name: Install common packages
      apt:
        name:
          - curl
          - wget
          - htop
          - vim
          - git
          - tree
        state: present

    - name: Check installed packages
      command: dpkg -l
      register: packages

    - name: Count installed packages
      debug:
        msg: "Total packages installed: {{ packages.stdout_lines | length }}"
"@ | Out-File -FilePath "ansible\package-management.yml" -Encoding UTF8

Write-Host "=== 설정 완료 ===" -ForegroundColor Green
Write-Host ""
Write-Host "다음 명령어로 환경을 시작하세요:" -ForegroundColor Cyan
Write-Host "docker-compose up -d" -ForegroundColor White
Write-Host ""
Write-Host "Ansible 서버에 접속하려면:" -ForegroundColor Cyan
Write-Host "docker exec -it ansible-server bash" -ForegroundColor White
Write-Host ""
Write-Host "테스트 명령어:" -ForegroundColor Cyan
Write-Host "ansible all -m ping" -ForegroundColor White
Write-Host "ansible-playbook test-playbook.yml" -ForegroundColor White
Write-Host "ansible-playbook system-info.yml" -ForegroundColor White
Write-Host "ansible-playbook package-management.yml" -ForegroundColor White