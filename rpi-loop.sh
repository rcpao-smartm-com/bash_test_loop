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
