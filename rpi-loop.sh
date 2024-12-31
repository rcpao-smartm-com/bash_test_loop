#!/bin/bash 


function wait_for_fping() {
  local SSH_HOST=$1 # the hostname or IP address to ping
  local FPING_RC=$2 # the return code to wait for

  w=0
  fping -c 1 ${SSH_HOST} > /dev/null 2>&1
  RC=$?
  while [ ${RC} -ne ${FPING_RC} ]; do
    w=$((w+1))
    echo -e -n "\b\b\b\b$w "
    sleep 1  # Adjust the sleep interval as needed

    fping -c 1 ${SSH_HOST} > /dev/null 2>&1
    RC=$?
  done

  echo "fping -c 1 ${SSH_HOST} RC=${RC}" 
} # wait_for_fping


function wait_for_ssh_cmd() {
  local SSH_DST=$1 # ssh destination
  local SSH_CMD="$2" # ssh command
  local SSH_RC=$3 # the return code to wait for
  local RC=-1

  w=0
  ssh ${SSH_DST} "${SSH_CMD}" > /dev/null 2>&1
  RC=$?
  while [ ${RC} -ne ${SSH_RC} ]; do
    w=$((w+1))
    echo -e -n "\b\b\b\b$w "
    sleep 1  # Adjust the sleep interval as needed

    ssh ${SSH_DST} "${SSH_CMD}" > /dev/null 2>&1
    RC=$?
  done

  echo "ssh ${SSH_DST} ${SSH_CMD} RC=${RC}" 
} # wait_for_ssh_cmd


function wait_for_scp() {
  local SCP_SRC=$1 # scp source filespec
  local SCP_DST=$2 # scp destination filespec
  local SCP_RC=$3 # the return code to wait for
  local RC=-1

  w=0
  scp ${SCP_SRC} ${SCP_DST} > /dev/null 2>&1
  RC=$?
  while [ ${RC} -ne ${SCP_RC} ]; do
    w=$((w+1))
    echo -e -n "\b\b\b\b$w "
    sleep 1  # Adjust the sleep interval as needed

    scp ${SCP_SRC} ${SCP_DST} > /dev/null 2>&1
    RC=$?
  done

  echo "scp ${SCP_SRC} ${SCP_DST} RC=${RC}" 
} # wait_for_scp


: <<'EOF'
SSH_USER=rcpao
SSH_HOST=ub24d-1t-mgef 
# SSH_ARP_A=$(arp -a ub24d-1t-mgef) # ub24d-1t-mgef.rs.paonet.org (172.18.128.200) at <incomplete> on eth0
# SSH_MAC="40:8d:5c:5e:40:36" # $(echo "$SSH_ARP_A" | cut -d ' ' -f 4) # <incomplete>
  # wakeonlan does not turn on Gigabyte GA-Z97X-Gaming_7 
  # wakeonlan does not have an equivalent to power off; thus, wakeonlan is not useful for power cycle testing
EOF
#: <<'EOF'
SSH_USER=smart
#SSH_HOST=fw40-070x 
#SSH_HOST=deb12-8-0-067x
SSH_HOST=ub24d-900g-00EX
#EOF

: <<'EOF'
BMC_IP="172.18.128.103" # 7C:C2:55:E6:F6:FC # Supermicro X14SBM-TF, CXL 2.0
BMC_USER="ADMIN"
BMC_PW="TGRMCKRDBV"
EOF
#: <<'EOF'
BMC_IP="172.18.128.55" # 3c:ec:ef:d9:75:38 # Supermicro X13SEM-F
BMC_USER="ADMIN"
BMC_PW="ITUDHIWUYO"
#EOF

NUM_LOOP=1000

sudo apt -y install fping wakeonlan ipmitool

for ((i=0; i < ${NUM_LOOP}; i++)); do
  echo "Iteration: $i of ${NUM_LOOP}"
  date
  echo "Power ON"
  if [ ! -z "$BMC_IP" ]; then
    ipmitool -H ${BMC_IP} -U ${BMC_USER} -P ${BMC_PW} power on
  elif [ ! -z "$SSH_MAC" ]; then
    wakeonlan ${SSH_MAC} # must have transmitted an Ethernet packet to populate the ARP table
    echo "warning: must use 'ipmitool power off' or 'IoT Relay' to power off"
  else
    python rpi/ctrlOn.py # IoT Relay
  fi

  #sleep 210 # wait for ${SSH_HOST} to start listening

  wait_for_fping ${SSH_HOST} 0
  echo "Host ${SSH_HOST} replied to fping.  Continuing." 
  # ${SSH_HOST} should now be listening 

  wait_for_ssh_cmd "${SSH_USER}@${SSH_HOST}" 'echo hi' 0
  RC=$?
  [ ${RC} -ne 0 ] && exit ${RC}

  ssh "${SSH_USER}@${SSH_HOST}" 'ls bin/'
  RC=$?
  if [ ${RC} -ne 0 ]; then
    wait_for_ssh_cmd "${SSH_USER}@${SSH_HOST}" 'mkdir bin/' 0
    RC=$?
    [ ${RC} -ne 0 ] && exit ${RC}
  fi

  wait_for_scp test1.sh ${SSH_USER}@${SSH_HOST}:bin/ 0
  RC=$?
  [ ${RC} -ne 0 ] && exit ${RC}

  if [[ $i -eq 1 ]]; then
    time ssh ${SSH_USER}@${SSH_HOST} rm interval.txt log.txt
  fi

  ssh ${SSH_USER}@${SSH_HOST} bin/test1.sh

  #sleep 60 # test1.sh 'shutdown -h now' should be off before power_off is run
  wait_for_fping ${SSH_HOST} 1
  echo "Host ${SSH_HOST} did not reply to fping.  Continuing." 

  set -x
  sleep 20 # test1 should be off for a minimum of this many seconds to allow all hw devices to bleed power off
  echo "Power OFF"
  if [ ! -z "$BMC_IP" ]; then
    ipmitool -H ${BMC_IP} -U ${BMC_USER} -P ${BMC_PW} power off
  elif [ ! -z "$SSH_MAC" ]; then
    # wakeonlan ${SSH_MAC} # 40:8d:5c:5e:40:36 # must have transmitted an Ethernet packet to populate the ARP table
    #wakeonlan ${SSH_MAC} # 40:8d:5c:5e:40:36
    echo "error: use 'ipmitool power off' or 'IoT Relay' to power off"
    exit 1
  else
    python rpi/ctrlOff.py # IoT Relay
  fi
  sleep 10 # test1 should be off for a minimum of this many seconds to allow all hardware to drain power off
  set +x
done

echo "Iteration: $i of ${NUM_LOOP} done"
