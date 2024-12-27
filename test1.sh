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

