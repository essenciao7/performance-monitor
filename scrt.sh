#!/bin/bash

# Create timestamp for apending filenames
TIMESTAMP=$(date +"%Y%m%d")

#!/bin/bash

# SSH接続情報、本番環境
SSH_USER=root
SSH_PASS=default
SSH_HOSTNAMES=('AFTVP03')
SSH_HOSTS=('10.128.1.145')

# ログの保存場所
LOG_PATH=~/Desktop/var/log

# CPUやメモリ利用率を取得するためのリモートコマンド
REMOTE_CMD_CPU="tmsh show sys cpu | grep Util% | awk '{print $8}'"
REMOTE_CMD_MEMORY="tmsh show sys memory"


# 後述のSSH_ASKPASSで設定したプログラム(本ファイル自身)が返す内容
if [ -n "$PASSWORD" ]; then
  cat <<< "$PASSWORD"
  exit 0
fi

# パスワードを渡すための変数を設定し、本ファイルをSSH_ASKPASSに設定する
export PASSWORD=$SSH_PASS
export SSH_ASKPASS=$0

# ダミーなDISPLAY
export DISPLAY=dummy:0

# 性能情報取得のメイン処理
for i in "${!SSH_HOSTS[@]}"; do
   mkdir -p ${LOG_PATH}
   setsid -f ssh ${SSH_USER}@${SSH_HOSTS[$i]} ${REMOTE_CMD_CPU}>>${LOG_PATH}/vpn-${SSH_HOSTNAMES[$i]}-cpu
   setsid -f ssh ${SSH_USER}@${SSH_HOSTS[$i]} ${REMOTE_CMD_MEMORY}>>${LOG_PATH}/vpn-${SSH_HOSTNAMES[$i]}-memory
done