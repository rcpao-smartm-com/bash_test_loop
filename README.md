# README.md for bash_test_loop


## Raspberry Pi 

Raspberry Pi runs a loop.  Each loop makes an ssh connection to a Linux
Tester to run a test script.

rpi-loop.sh
```
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


SSH_USER=rcpao
SSH_HOST=ub24d-1t-mgef 
SSH_ARP_A=$(arp -a ub24d-1t-mgef) # ub24d-1t-mgef.rs.paonet.org (172.18.128.200) at <incomplete> on eth0
SSH_MAC=$(echo "$SSH_ARP_A" | cut -d ' ' -f 4) # <incomplete>

NUM_LOOP=100

for ((i=0; i < ${NUM_LOOP}; i++)); do
  echo "Iteration: $i of ${NUM_LOOP}"
  date
  echo "Power ON"
  python rpi/ctrlOn.py

  #sleep 210 # wait for ${SSH_HOST} to start listening
  # wakeonlan ${SSH_MAC} # 40:8d:5c:5e:40:36 # must have transmitted an Ethernet packet to populate the ARP table
  wakeonlan 40:8d:5c:5e:40:36
  wait_for_fping ${SSH_HOST} 0
  echo "Host ${SSH_HOST} replied to fping" 
  # ${SSH_HOST} should now be listening 

  if [[ $i -eq 1 ]]; then
    time ssh ${SSH_USER}@${SSH_HOST} rm interval.txt log.txt
  fi

  time scp test1.sh ${SSH_USER}@${SSH_HOST}:bin/
  time ssh ${SSH_USER}@${SSH_HOST} bin/test1.sh
  #sleep 60 # test1.sh 'shutdown -h now' should be off before power_off is run
  wait_for_fping ${SSH_HOST} 1
  echo "Host ${SSH_HOST} did not reply to fping" 

  set -x
  echo "Power OFF"
  sleep 10 # test1 should be off for a minimum of this many seconds to allow all hw devices to bleed power off
  python rpi/ctrlOff.py
  sleep 10 # test1 should be off for a minimum of this many seconds to allow all hw devices to bleed power off
  python rpi/ctrlOff.py
  sleep 10 # test1 should be off for a minimum of this many seconds to allow all hw devices to bleed power off
  set +x
done

echo "Iteration: $i of ${NUM_LOOP} done"
```


## Linux Tester

The test script logs everything to a log file.  Each run will log the
date and time, iteration (number of times the test script has run),
and test results.

test1.sh:
```
#!/bin/bash -vx

LOG=log.txt

date | tee -a $LOG

NUMFILE=iteration.txt
expr `cat $NUMFILE 2>/dev/null` + 1 >$NUMFILE
ITERATION=$(cat $NUMFILE)
echo "Iteration: $ITERATION" | tee -a $LOG

echo "test 1" | tee -a $LOG
echo "test 2" | tee -a $LOG
echo "test 3" | tee -a $LOG

echo "shutdown -h now" | tee -a $LOG
date | tee -a $LOG
sudo shutdown -h now; date | tee -a $LOG
  # /etc/sudoers.d/rcpao
  # rcpao    ALL=(ALL:ALL) NOPASSWD:ALL
```
