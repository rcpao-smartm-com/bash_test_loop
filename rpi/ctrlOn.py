#Python Script to turn on a Rasberry Pi electrical signal

import RPi.GPIO as GPIO # Import IO package for Rsp Pi

PIN_GPIO = 17 # Sets Current IO Pin to 17

GPIO.setwarnings(False) # Diable Warnings
GPIO.setmode(GPIO.BCM) # Set the IO Numbering Mode to BCM
GPIO.setup(PIN_GPIO, GPIO.OUT) # Associate Pin 17 to output

GPIO.output(PIN_GPIO, True) # activate output
