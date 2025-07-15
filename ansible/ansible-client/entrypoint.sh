#!/bin/bash

# authorized_keys 파일 설정
cat /home/ansible_user/id_rsa.pub > /home/ansible_user/.ssh/authorized_keys
chown ansible_user:ansible_user /home/ansible_user/.ssh/authorized_keys
chmod 600 /home/ansible_user/.ssh/authorized_keys

# Dockerfile의 원래 CMD 실행
exec "$@"