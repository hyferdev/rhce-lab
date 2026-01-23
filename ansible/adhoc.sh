#!/bin/bash

# Ensure Environment Variables are set
if [ -z "$PH" ] || [ -z "$PK" ]; then
  echo "Error: PH (Password Hash) and PK (Public Key) environment variables must be set."
  echo "Usage: export PH='$.8iuuI5/1jqTeSE...'; export PK='ssh-rsa AAAA...'"
  exit 1
fi

echo "--- 1. Install Python3.9 ---"
ansible all -b -m raw -a "sudo dnf install -y python3.9"

echo "--- 2. Creating User 'automation' ---"
ansible all -b -m user -a "name=automation password=$PH shell=/bin/bash groups=wheel"

echo "--- 3. Deploying SSH Key for 'automation' ---"
ansible all -b -m authorized_key -a "user=automation state=present key='$PK'"

echo "--- 4. Configuring Passwordless Sudo ---"
ansible all -b -m copy -a "content='automation ALL=(ALL) NOPASSWD: ALL' dest=/etc/sudoers.d/automation mode=0440 validate='visudo -cf %s'"

echo "--- Setup Complete ---"