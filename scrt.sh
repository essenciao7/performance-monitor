#!/bin/bash

TIMESTAMP=$(date +"%b %d %H:%M:%S")

# 設定ファイルを読み込み
source /Users/j367557/Documents/workspace/apm/vpnrsc.conf


# 性能情報取得のメイン処理
for i in "${!SSH_HOSTS[@]}"; do

  # 後述のSSH_ASKPASSで設定したプログラム(本ファイル自身)が返す内容
  if [ -n "$PASSWORD" ]; then
    cat <<< "$PASSWORD"
    exit 0
  fi

  # パスワードを渡すための変数を設定し、本ファイルをSSH_ASKPASSに設定する
  export PASSWORD=${SSH_PASS[$i]}
  export SSH_ASKPASS=$0

  # ダミーなDISPLAY
  export DISPLAY=dummy:0

  mkdir -p ${LOG_PATH}
  CPU_USAGE=($(setsid -f ssh ${SSH_USER}@${SSH_HOSTS[$i]} ${REMOTE_CMD_CPU} | awk 'NR==6 {print $2}'))
  MEM_USAGE=($(setsid -f ssh ${SSH_USER}@${SSH_HOSTS[$i]} ${REMOTE_CMD_MEMORY} | awk 'NR==6 {print $4}'))
  unset PASSWORD
  
# CPUログレベルの設定
  if [ $CPU_USAGE -lt $CPU_LOG_LEVEL_M ]; then
    CPU_LOG_LEVEL=N
  elif [ $CPU_USAGE -ge $CPU_LOG_LEVEL_M ] && [$CPU_USAGE -lt $CPU_LOG_LEVEL_C ]; then
    CPU_LOG_LEVEL=M
  else
    CPU_LOG_LEVEL=C
  fi

# メモリログレベルの設定
  if [ $MEM_USAGE -lt $MEM_LOG_LEVEL_M ]; then
    MEM_LOG_LEVEL=N
  elif [ $MEM_USAGE -ge $MEM_LOG_LEVEL_M ] && [ MEM_USAGE -lt $MEM_LOG_LEVEL_C ]; then
    MEM_LOG_LEVEL=M
  else
    MEM_LOG_LEVEL=C
  fi

  echo "$TIMESTAMP ${SSH_HOSTNAMES[$i]} $CPU_LOG_LEVEL cpumon: CPU utilization reached utilization $CPU_USAGE%." >> ${LOG_PATH}/vpn-cpu
  echo "$TIMESTAMP ${SSH_HOSTNAMES[$i]} $MEM_LOG_LEVEL memmon: Memory usage reached utilization $MEM_USAGE%." >> ${LOG_PATH}/vpn-memory
done