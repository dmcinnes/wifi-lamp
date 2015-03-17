# Arduino Make file. Refer to https://github.com/sudar/Arduino-Makefile

ARDMK_DIR = /usr/local/opt/arduino-mk

# if you have placed the alternate core in your sketchbook directory, then you can just mention the core name alone.
# ALTERNATE_CORE = attiny
ARDUINOSUB = Microduino
BOARD = 644pa16m
# If not, you might have to include the full path.
# ALTERNATE_CORE_PATH = /Users/doug/Documents/Arduino/hardware/attiny

# BOARD_TAG    = attiny84-8
ISP_PORT = /dev/ttyACM*

include $(ARDMK_DIR)/Arduino.mk
