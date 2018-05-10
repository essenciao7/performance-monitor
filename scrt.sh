#!/bin/bash

TIMESTAMP=$(date +"%Y%m%d%H%M")

# 接続先情報
SSH_USER=root
SSH_PASS=default
SSH_HOST=10.128.1.145
SSH_HOSTNAME=testapm1
LOG_PATH=~/Desktop/
REMOTE_CMD_CPU="tmsh show sys cpu"
REMOTE_CMD_MEMORY="tmsh show sys memory"


# 後述のSSH_ASKPASSで設定したプログラム(本ファイル自身)が返す内容
if [ -n "$PASSWORD" ]; then
  cat <<< "$PASSWORD"
  exit 0
fi

# SSH_ASKPASSで呼ばれるシェルにパスワードを渡すために変数を設定
export PASSWORD=$SSH_PASS

# SSH_ASKPASSに本ファイルを設定
export SSH_ASKPASS=$0
# ダミーを設定
export DISPLAY=dummy:0

# SSH接続 & リモートコマンド実行
exec setsid ssh ${SSH_USER}@${SSH_HOST} ${REMOTE_CMD_CPU}>${LOG_PATH}/${SSH_HOSTNAME}-cpu-${TIMESTAMP}.log
exec setsid ssh ${SSH_USER}@${SSH_HOST} ${REMOTE_CMD_MEMORY}>${LOG_PATH}/${SSH_HOSTNAME}-memory-${TIMESTAMP}.log
# exec setsid ssh $SSH_USER@$SSH_HOST $REMOTE_CMD_CPU > $LOG_PATH/${SSH_HOSTNAME}-cpu2-${TIMESTAMP}.log $REMOTE_CMD_MEMORY > $LOG_PATH/${SSH_HOSTNAME}-memory2-${TIMESTAMP}.log