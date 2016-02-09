#!/bin/bash
# This small shell script initializes the I2C bus on a Raspberry Pi
# and activates an installed real time clock module. 
# Afterwards the system time is synced to the hardware clock.

echo ds1307 0x68 > /sys/class/i2c-adapter/i2c-1/new_device
hwclock -s
