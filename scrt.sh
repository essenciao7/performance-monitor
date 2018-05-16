#!/bin/bash

# Create timestamp for apending filenames
TIMESTAMP=$(date +"%Y%m%d")

# SSH Connection Info
SSH_USER=root
SSH_PASS=default
SSH_HOSTNAMES=('AFTVP03' 'AFTVP04')
SSH_HOSTS=('10.128.1.145' '10.128.1.145')

# Specify Log Directory
LOG_PATH=~/Desktop/var/log

# Commands for checking cpu & memory usages
REMOTE_CMD_CPU="date; tmsh show sys cpu"
REMOTE_CMD_MEMORY="date; tmsh show sys memory"


# 後述のSSH_ASKPASSで設定したプログラム(本ファイル自身)が返す内容
if [ -n "$PASSWORD" ]; then
  cat <<< "$PASSWORD"
  exit 0
fi

# Prepare a PASSWORD for the SSH_ASKPASS-shell
export PASSWORD=$SSH_PASS

# Set SSH_ASKPASS to THIS file
export SSH_ASKPASS=$0

# A dummy DISPLAY
export DISPLAY=dummy:0

# Main transactions
for i in "${!SSH_HOSTS[@]}"; do
   echo "Logging on ${SSH_HOSTS[$i]}..."
   mkdir -p ${LOG_PATH}
   setsid -f ssh ${SSH_USER}@${SSH_HOSTS[$i]} ${REMOTE_CMD_CPU}>>${LOG_PATH}/vpn-${SSH_HOSTNAMES[$i]}-cpu.log
   setsid -f ssh ${SSH_USER}@${SSH_HOSTS[$i]} ${REMOTE_CMD_MEMORY}>>${LOG_PATH}/vpn-${SSH_HOSTNAMES[$i]}-memory.log
   echo "Logged out ${SSH_HOSTS[$i]}..."
done