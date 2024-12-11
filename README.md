# README.md for iot_relay_test_loop


## Raspberry Pi 

Raspberry Pi runs a loop.  Each loop makes an ssh connection to a Linux
Tester to run a test script.

loop_test1.sh:
NUM_LOOP=3
for i in (1..$NUM_LOOPS); do
  echo "Iteration: $i of $NUM_LOOPS"
  date
  power_on
  sleep 120 # wait for ssh-server to start listening
  # ssh-server must now be listening 

  # time ssh $USER@127.0.0.1 "test1.sh" # run via ssh
  time ./test1.sh # run locally

  sleep 60 # test1.sh 'shutdown -h now' should be off before power_off is run
  power_off 
  sleep 60 # test1 should be off for a minimum of this many seconds to allow all hw devices to power off
done


## Linux Tester

The test script logs everything to a log file.  Each run will log the
date and time, iteration (number of times the test script has run),
and test results.

test1.sh:
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

echo shutdown -h now" | tee -a $LOG
#shutdown -h now
