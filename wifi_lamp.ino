#include <SPI.h>
#include <LPD8806.h>
#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include "wifi_creds.h"

typedef void (*lampAction)(unsigned long);
lampAction currentLampAction;

ESP8266WebServer server(80);

#define LED_COUNT 16

#define DATA_PIN  0
#define CLOCK_PIN 2

unsigned long lastMillis;

LPD8806 strip = LPD8806(LED_COUNT, DATA_PIN, CLOCK_PIN);

void OK() {
  server.send(200, "text/plain", "OK");
}

void setupServer() {
  server.on("/", []() {
    server.send(200, "text/plain", "Hello from esp8266!");
  });

  server.on("/off", HTTP_POST, [](){
    clear();
    currentLampAction = &none;
    OK();
  });

  server.on("/blobs", HTTP_POST, [](){
    clear();
    currentLampAction = &blobs;
    OK();
  });

  server.on("/bubble", HTTP_POST, [](){
    clear();
    currentLampAction = &bubble;
    OK();
  });

  server.on("/rainbow", HTTP_POST, [](){
    clear();
    currentLampAction = &rainbow;
    OK();
  });

  server.on("/rainbow-cycle", HTTP_POST, [](){
    clear();
    currentLampAction = &rainbowCycle;
    OK();
  });

  server.on("/red", HTTP_POST, [](){
    for (unsigned int i=0; i < LED_COUNT; i++) {
      strip.setPixelColor(i, wheel(0));
    }
    strip.show();
    currentLampAction = &none;
    OK();
  });
}

void setup(void) {
  Serial.begin(115200);

  // Connect to WiFi network
  WiFi.begin(WLAN_SSID, WLAN_PASS);
  Serial.println("");

  strip.begin();

  strip.show();

  // Wait for connection
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.print("Connected to ");
  Serial.println(WLAN_SSID);
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());

  setupServer();

  server.begin();
  Serial.println("HTTP server started");

  lastMillis = millis();
  randomSeed(analogRead(0));

  currentLampAction = &blobs;
}

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
        strip.setPixelColor(led, 0, 0, color + 50);
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

// a few from Adafruit's strandtest

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

void rainbowCycle(unsigned long delta) {
  uint16_t i, j;

  rainbowTimeout += delta;
  if (rainbowTimeout > rainbowDelay) {
    rainbowTimeout -= rainbowDelay;
    rainbowOffset++;
    if (rainbowOffset > 384) {
      rainbowOffset = 0;
    }

    for (i=0; i < strip.numPixels(); i++) {
      // tricky math! we use each pixel as a fraction of the full 384-color wheel
      // (thats the i / strip.numPixels() part)
      // Then add in j which makes the colors go around per pixel
      // the % 384 is to make the wheel cycle around
      strip.setPixelColor(i, wheel( ((i * 384 / LED_COUNT) + rainbowOffset) % 384) );
    }
    strip.show();   // write all the pixels out
  }
}

const unsigned int blobCount = 3;
unsigned int blobUpdateOn[] = {0, 0, 0};
unsigned int blobTimers[] = {0, 0, 0};
int blobList[]   = {0, 0, 0};
void blobs(unsigned long delta) {
  bool show = false;
  int dir, color, blobLed;
  unsigned int i, j, led;

  for (i = 0; i < blobCount; i++) {
    blobTimers[i] += delta;
    if (blobTimers[i] > blobUpdateOn[i]) {
      blobTimers[i] = blobTimers[i] - blobUpdateOn[i];

      if (blobList[i] == 0) {
        blobList[i] = random(1, LED_COUNT+1);
        blobTimers[i] = 0;
        blobUpdateOn[i] = random(60, 100);
      }
      dir = (blobList[i] < 0) ? -1 : 1;
      led = dir * blobList[i] - 1;
      for (j = 0; j < 3; j++) {
        blobLed = led + j - 1;
        if (blobLed >= 0 && blobLed < LED_COUNT) {
          color = strip.getPixelColor(blobLed) & 0x7f;
          color += (dir * ((j == 1) ? 10 : 1));
          if (color <= 0) {
            color = 0;
            if (j == 1) {
              // end
              blobList[i] = 0;
            }
          } else if (color >= 127) {
            color = 127;
            if (j == 1) {
              // reverse
              blobList[i] = -blobList[i];
            }
          }
          strip.setPixelColor(blobLed, 0, 0, color);
          show = true;
        }
      }
    }
  }
  if (show) {
    strip.show();
  }
}

void clear() {
  for (unsigned int i=0; i < LED_COUNT; i++) {
    strip.setPixelColor(i, 0);
  }
  strip.show();
}

void none(unsigned long delta) {
}

void loop(void) {
  unsigned long currentMillis = millis();
  unsigned long delta = currentMillis - lastMillis;
  lastMillis = currentMillis;

  (*currentLampAction)(delta);

  server.handleClient();

  // let the WIFI stack do its thing
  yield();
}
