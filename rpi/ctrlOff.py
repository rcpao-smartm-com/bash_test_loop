#Python Script to turn off a Rasberry Pi electrical signal

import RPi.GPIO as GPIO

PIN_GPIO = 17

GPIO.setwarnings(False)
GPIO.setmode(GPIO.BCM)
GPIO.setup(PIN_GPIO, GPIO.OUT)

GPIO.output(PIN_GPIO, False) # prior code does the same as ctrlOn, but deactivates the pin instead
