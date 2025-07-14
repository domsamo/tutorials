@echo off
echo === Ansible Docker 환경 설정 시작 ===

:: 필요한 디렉토리 생성
echo 디렉토리 생성 중...
if not exist "ansible" mkdir ansible
if not exist "ssh-keys" mkdir ssh-keys

:: SSH 키 생성 (이미 존재하지 않는 경우)
if not exist "ssh-keys\id_rsa" (
    echo SSH 키 생성 중...
    docker run --rm -v "%cd%\ssh-keys:/tmp/ssh-keys" alpine:latest sh -c "apk add --no-cache openssh-client && ssh-keygen -t rsa -b 4096 -f /tmp/ssh-keys/id_rsa -N '' && cp /tmp/ssh-keys/id_rsa.pub /tmp/ssh-keys/authorized_keys"
    echo SSH 키 생성 완료
) else (
    echo SSH 키가 이미 존재합니다.
)

:: Ansible 설정 파일 생성
echo Ansible 설정 파일 생성 중...
(
echo [defaults]
echo host_key_checking = False
echo inventory = inventory
echo remote_user = root
echo private_key_file = /root/.ssh/id_rsa
echo timeout = 30
echo.
echo [ssh_connection]
echo ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
) > ansible\ansible.cfg

:: 샘플 playbook 생성
echo 샘플 playbook 생성 중...
(
echo ---
echo - name: Test Ansible Connection
echo   hosts: clients
echo   gather_facts: yes
echo   tasks:
echo     - name: Ping test
echo       ping:
echo.
echo     - name: Get hostname
echo       command: hostname
echo       register: hostname_result
echo.
echo     - name: Display hostname
echo       debug:
echo         msg: "Hostname: {{ hostname_result.stdout }}"
echo.
echo     - name: Install basic packages
echo       apt:
echo         name:
echo           - curl
echo           - wget
echo           - htop
echo         state: present
echo         update_cache: yes
) > ansible\test-playbook.yml

:: 시스템 정보 수집 playbook
echo 추가 playbook 생성 중...
(
echo ---
echo - name: System Information Gathering
echo   hosts: clients
echo   gather_facts: yes
echo   tasks:
echo     - name: Display system information
echo       debug:
echo         msg: ^|
echo           OS: {{ ansible_distribution }} {{ ansible_distribution_version }}
echo           Kernel: {{ ansible_kernel }}
echo           Architecture: {{ ansible_architecture }}
echo           Memory: {{ ansible_memtotal_mb }} MB
echo           CPU: {{ ansible_processor_cores }} cores
echo.
echo     - name: Check disk usage
echo       command: df -h
echo       register: disk_usage
echo.
echo     - name: Display disk usage
echo       debug:
echo         var: disk_usage.stdout_lines
) > ansible\system-info.yml

echo === 설정 완료 ===
echo.
echo 다음 명령어로 환경을 시작하세요:
echo docker-compose up -d
echo.
echo Ansible 서버에 접속하려면:
echo docker exec -it ansible-server bash
echo.
echo 테스트 명령어:
echo ansible all -m ping
echo ansible-playbook test-playbook.yml
echo ansible-playbook system-info.yml
echo.
pause