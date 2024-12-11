#!/bin/bash 

NUM_LOOP=3
for i in (1..$NUM_LOOPS); do
  echo "Iteration: $i of $NUM_LOOPS"
  date
  echo "power_on"
  sleep 120 # wait for ssh-server to start listening
  # ssh-server must now be listening 

  # time ssh $USER@127.0.0.1 "test1.sh" # run via ssh
  time ./test1.sh # run locally

  sleep 60 # test1.sh 'shutdown -h now' should be off before power_off is run
  echo "power_off"
  sleep 60 # test1 should be off for a minimum of this many seconds to allow all hw devices to power off
done
