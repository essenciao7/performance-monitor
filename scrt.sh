#!/bin/bash

# Create timestamp for apending filenames
# TIMESTAMP=$(date +"%Y%m%d")
TIMESTAMP=$(date +"%b %d %H:%M:%S")

#!/bin/bash

# SSH接続情報、本番環境
SSH_USER=root
SSH_PASS=default
SSH_HOSTNAMES=('AFTVP03' 'AFTVP04')
SSH_HOSTS=('10.128.1.145' '10.128.1.145')

# ログの保存場所
LOG_PATH=~/Desktop/var/log

# CPUやメモリ利用率を取得するためのリモートコマンド
REMOTE_CMD_CPU="tmsh show sys cpu"
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
  CPU_USAGE=($(setsid -f ssh ${SSH_USER}@${SSH_HOSTS[$i]} ${REMOTE_CMD_CPU} | awk 'NR==6 {print $2}'))
  MEM_USAGE=($(setsid -f ssh ${SSH_USER}@${SSH_HOSTS[$i]} ${REMOTE_CMD_MEMORY} | awk 'NR==6 {print $4}'))

# CPUログレベルの設定
  if [ $CPU_USAGE -ge "80" ]; then
    CPU_LOG_LEVEL=alert
  elif [ $CPU_USAGE -lt "80" ] && [ $CPU_USAGE -ge "50" ]; then
    CPU_LOG_LEVEL=warning
  else
    CPU_LOG_LEVEL=info
  fi

# メモリログレベルの設定
  if [ $MEM_USAGE -ge "80" ]; then
    MEM_LOG_LEVEL=alert
  elif [ $MEM_USAGE -lt "80" ] && [ $MEM_USAGE -ge "50" ]; then
    MEM_LOG_LEVEL=warning
  else
    MEM_LOG_LEVEL=info
  fi

  echo "$TIMESTAMP ${SSH_HOSTNAMES[$i]} $CPU_LOG_LEVEL cpumon: CPU utilization reached utilization $CPU_USAGE%." >> ${LOG_PATH}/vpn-cpu
  echo "$TIMESTAMP ${SSH_HOSTNAMES[$i]} $MEM_LOG_LEVEL memmon: Memory usage reached utilization $MEM_USAGE%." >> ${LOG_PATH}/vpn-memory
done