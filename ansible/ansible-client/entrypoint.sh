#!/bin/bash

# authorized_keys 파일 설정
# 주의 : 이파일은 반드시 LF로 라인 줄바꿈이 되어 있어야 함 (CRLF 일 경우 실행 오류 발생)
cat /home/ansible_user/id_rsa.pub > /home/ansible_user/.ssh/authorized_keys
chown ansible_user:ansible_user /home/ansible_user/.ssh/authorized_keys
chmod 600 /home/ansible_user/.ssh/authorized_keys

# Dockerfile의 원래 CMD 실행
exec "$@"