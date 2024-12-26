# README.md for bash_test_loop


## Raspberry Pi 

Raspberry Pi runs a loop.  Each loop makes an ssh connection to a Linux
Tester to run a test script.

rpi-loop.sh
```
#!/bin/bash 

NUM_LOOP=3
for i in (1..$NUM_LOOPS); do
  echo "Iteration: $i of $NUM_LOOPS"
  date
  echo "Power ON"
  python rpi/ctrlOn.py
  sleep 210 # wait for ssh-server to start listening
  # ssh-server must now be listening 

  time ssh rcpao@ub24d-1t-mgef bin/test1.sh
  sleep 60 # test1.sh 'shutdown -h now' should be off before power_off is run

  echo "Power OFF"
  python rpi/ctrlOn.py
  sleep 60 # test1 should be off for a minimum of this many seconds to allow all hw devices to power off
done
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
sudo shutdown -h now
date | tee -a $LOG
```
