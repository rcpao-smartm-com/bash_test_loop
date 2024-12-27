#!/bin/bash -vx

LOG=log.txt

date | tee -a $LOG

NUMFILE=iteration.txt
expr `cat $NUMFILE 2>/dev/null` + 1 >$NUMFILE
ITERATION=$(cat $NUMFILE)
echo "Iteration: $ITERATION" | tee -a $LOG

echo "lsmem" | tee -a $LOG
lsmem >> $LOG
RC=$?
[ ${RC} -ne 0 ] && echo "error: 'lsmem' returned ${RC}" && exit ${RC}

echo "numactl -H" | tee -a $LOG
numactl -H >> $LOG
[ ${RC} -ne 0 ] && echo "error: 'numactl -H' returned ${RC}" && exit ${RC}

# echo "test 1" | tee -a $LOG
# echo "test 2" | tee -a $LOG
# echo "test 3" | tee -a $LOG

echo "shutdown -h now" | tee -a $LOG
date | tee -a $LOG
sudo shutdown -h now; date | tee -a $LOG
  # /etc/sudoers.d/rcpao
  # rcpao    ALL=(ALL:ALL) NOPASSWD:ALL

