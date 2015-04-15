#include <LPD8806.h>

#define LED_COUNT 16

#define DATA_PIN  3
#define CLOCK_PIN 4

typedef void (*lampAction)(unsigned long);
lampAction currentLampAction;

unsigned long lastMillis;

LPD8806 strip = LPD8806(LED_COUNT, DATA_PIN, CLOCK_PIN);

// Input a value 0 to 384 to get a color value.
// The colours are a transition r - g -b - back to r

uint32_t wheel(uint16_t WheelPos) {
  byte r, g, b;
  switch(WheelPos / 128) {
    case 0:
      r = 127 - WheelPos % 128; // Red down
      g = WheelPos % 128;       // Green up
      b = 0;                    // blue off
      break;
    case 1:
      g = 127 - WheelPos % 128; // green down
      b = WheelPos % 128;       // blue up
      r = 0;                    // red off
      break;
    case 2:
      b = 127 - WheelPos % 128; // blue down
      r = WheelPos % 128;       // red up
      g = 0;                    // green off
      break;
  }
  return(strip.Color(r,g,b));
}

const unsigned int bubbleCount = 5;
unsigned int bubbleUpdateOn[] = {0, 0, 0, 0, 0};
unsigned int bubbleTimers[]   = {0, 0, 0, 0, 0};
unsigned int bubbleLeds[]     = {0, 0, 0, 0, 0};
void bubble(unsigned long delta) {
  bool show = false;
  unsigned int i, led, color;

  for (i = 0; i < bubbleCount; i++) {
    if (bubbleUpdateOn[i] == 0) {
      bubbleUpdateOn[i] = random(30, 150);
    }

    bubbleTimers[i] += delta;

    if (bubbleTimers[i] > bubbleUpdateOn[i]) {
      bubbleTimers[i] -= bubbleUpdateOn[i];
      led = bubbleLeds[i];
      if (led > 0) {
        strip.setPixelColor(led - 1, 0, 0, 0);
      }
      if (led < LED_COUNT) {
        color = strip.getPixelColor(led) & 0x7f;
        strip.setPixelColor(led, 0, 0, color + 20);
        bubbleLeds[i] = led + 1;
      } else {
        // reset
        bubbleLeds[i]     = 0;
        bubbleUpdateOn[i] = 0;
        bubbleTimers[i]   = 0;
      }
      show = true;
    }
  }
  if (show) {
    strip.show();
  }
}

const unsigned int rainbowDelay = 50;
unsigned int rainbowOffset  = 0;
unsigned int rainbowTimeout = 0;
void rainbow(unsigned long delta) {
  unsigned int i;

  rainbowTimeout += delta;
  if (rainbowTimeout > rainbowDelay) {
    rainbowTimeout -= rainbowDelay;
    rainbowOffset++;
    if (rainbowOffset > 384) {
      rainbowOffset = 0;
    }
    for (i=0; i < LED_COUNT; i++) {
      strip.setPixelColor(i, wheel( (i + rainbowOffset) % 384));
    }
    strip.show();
  }
}

void setup(void) {
  strip.begin();
  strip.show();

  lastMillis = millis();
  randomSeed(analogRead(2));

  currentLampAction = &rainbow;
}

void loop(void) {
  unsigned long currentMillis = millis();
  unsigned long delta = currentMillis - lastMillis;
  lastMillis = currentMillis;

  (*currentLampAction)(delta);
}
