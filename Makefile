# Arduino Make file. Refer to https://github.com/sudar/Arduino-Makefile

ARDUINO_DIR = /Applications/Arduino-esp8266-latest.app/Contents/Java

ARDMK_DIR = /usr/local/opt/arduino-mk

# if you have placed the alternate core in your sketchbook directory, then you can just mention the core name alone.
# ALTERNATE_CORE = esp8266com
# ARDUINOSUB = generic
# BOARD = esp8266
# If not, you might have to include the full path.
ALTERNATE_CORE_PATH = /Applications/Arduino-esp8266-latest.app/Contents/Java/hardware/esp8266com/esp8266
BOARD = generic

# BOARD_TAG    = attiny84-8

include $(ARDMK_DIR)/Arduino.mk
