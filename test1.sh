#!/bin/bash -vx

LOG=log.txt

date | tee -a $LOG

NUMFILE=iteration.txt
expr `cat $NUMFILE 2>/dev/null` + 1 >$NUMFILE
ITERATION=$(cat $NUMFILE)
echo "Iteration: $ITERATION" | tee -a $LOG


date | tee -a $LOG
echo "lspci" # | tee -a $LOG
LLOG=lspci.txt
lspci > $LLOG 2>&1
RC=$?
[ ${RC} -ne 0 ] && echo "error: 'lspci' returned ${RC}" && exit ${RC}
cat $LLOG
cat $LLOG >> $LOG


date | tee -a $LOG
echo "lsmem" # | tee -a $LOG
LLOG=lsmem.txt
lsmem > $LLOG 2>&1
RC=$?
[ ${RC} -ne 0 ] && echo "error: 'lsmem' returned ${RC}" && exit ${RC}
cat $LLOG
cat $LLOG >> $LOG


date | tee -a $LOG
echo "numactl -H" # | tee -a $LOG
LLOG=numactl_-H.txt
numactl -H > $LLOG 2>&1
RC=$?
[ ${RC} -ne 0 ] && echo "error: 'numactl -H' returned ${RC}" && exit ${RC}
cat $LLOG
cat $LLOG >> $LOG
grep "node 1" $LLOG >> $LOG
RC=$?
[ ${RC} -ne 0 ] && echo "error: \'grep \"node 1\" $LLOG\' returned ${RC}" && exit ${RC}


#: <<'EOF'
MLC=~/Downloads/mlc_v3.10/Linux/mlc

date | tee -a $LOG
echo "numactl --membind=0 $MLC"
LLOG=numactl_--membind=0_mlc.txt
numactl --membind=0 $MLC > $LLOG 2>&1
RC=$?
[ ${RC} -ne 0 ] && echo "error: \"numactl --membind=0 $MLC\" returned ${RC}" && exit ${RC}
cat $LLOG
cat $LLOG >> $LOG

date | tee -a $LOG
echo "numactl --membind=1 $MLC"
LLOG=numactl_--membind=1_mlc.txt
numactl --membind=1 $MLC > $LLOG 2>&1
RC=$?
[ ${RC} -ne 0 ] && echo "error: \"numactl --membind=1 $MLC\" returned ${RC}" && exit ${RC}
cat $LLOG
cat $LLOG >> $LOG
#EOF


# echo "test 1" | tee -a $LOG
# echo "test 2" | tee -a $LOG
# echo "test 3" | tee -a $LOG


echo "shutdown -h now" | tee -a $LOG
date | tee -a $LOG
sudo shutdown -h now; date | tee -a $LOG
  # /etc/sudoers.d/rcpao
  # rcpao    ALL=(ALL:ALL) NOPASSWD:ALL

