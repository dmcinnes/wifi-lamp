#include <Math.h>
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

byte R, G, B;

void sendOK() {
  server.send(200, "text/plain", "OK");
}

void setupServer() {
  server.on("/", []() {
    server.send(200, "text/plain", "Hello from esp8266!");
  });

  server.on("/off", HTTP_POST, [](){
    clear();
    currentLampAction = &none;
    sendOK();
  });

  server.on("/blobs", HTTP_POST, [](){
    clear();
    currentLampAction = &blobs;
    sendOK();
  });

  server.on("/bubble", HTTP_POST, [](){
    clear();
    setColorFromArgs();
    currentLampAction = &bubble;
    sendOK();
  });

  server.on("/rainbow", HTTP_POST, [](){
    clear();
    currentLampAction = &rainbow;
    sendOK();
  });

  server.on("/rainbow-cycle", HTTP_POST, [](){
    clear();
    currentLampAction = &rainbowCycle;
    sendOK();
  });

  server.on("/chase", HTTP_POST, [](){
    clear();
    setColorFromArgs();
    currentLampAction = &chase;
    sendOK();
  });

  server.on("/red", HTTP_POST, [](){
    R = 127;
    G = 0;
    B = 0;
    for (unsigned int i=0; i < LED_COUNT; i++) {
      strip.setPixelColor(i, R, G, B);
    }
    strip.show();
    currentLampAction = &none;
    sendOK();
  });

  server.on("/color", HTTP_POST, [](){
    setColorFromArgs();
    for (unsigned int i=0; i < LED_COUNT; i++) {
      strip.setPixelColor(i, R, G, B);
    }
    strip.show();
    currentLampAction = &none;
    sendOK();
  });
}

void setup(void) {
  // default solid color
  R = 0;
  G = 0;
  B = 128;

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
  unsigned int i, led;

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
        strip.setPixelColor(led, R, G, B);
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

const unsigned int blobCount = 5;
unsigned int blobColors[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
float blobOffsets[]       = {0.0, 0.0, 0.0, 0.0, 0.0};
float blobIndex[]         = {0.0, 0.0, 0.0, 0.0, 0.0};
float blobSpeed[]         = {0.0, 0.0, 0.0, 0.0, 0.0};
unsigned int blobWaits[]  = {0, 10, 20, 30, 40};
float blobAngle = 0;
const unsigned int blobDelay = 30;
unsigned int blobTimeout = 0;
void blobs(unsigned long delta) {
  unsigned int i, j, ledStart, r, g, b, WheelPos;
  float scale, blobScale, percent, nextBlob;

  blobAngle += PI * delta / 3000.0;
  if (blobAngle > 2 * PI) {
    blobAngle -= 2 * PI;
  }

  blobTimeout += delta;
  if (blobTimeout < blobDelay) {
    return;
  }
  blobTimeout -= blobDelay;

  // clear all the pixels
  for (i = 0; i < LED_COUNT; i++) {
    strip.setPixelColor(i, 0);
  }

  for (i = 0; i < blobCount; i++) {
    if (blobIndex[i] == 0 && blobWaits[i]-- == 0) {
      // don't double up blobs
      while (blobIndex[i] == 0) {
        nextBlob = float(random(1, LED_COUNT+1));
        for (j = 0; j < blobCount; j++) {
          if (blobIndex[i] == nextBlob) {
            nextBlob = 0;
            break;
          }
        }
        blobIndex[i] = nextBlob;
      }
      blobSpeed[i] = float(random(1, 100)) / 5000.0;
      // set the offset to right now plus some wiggle room
      blobOffsets[i] = PI - blobAngle + 0.25;
      WheelPos = random(385);
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
      blobColors[3*i]   = r;
      blobColors[3*i+1] = g;
      blobColors[3*i+2] = b;
    } else if (blobIndex[i] > 0) {
      blobIndex[i] += blobSpeed[i];

      ledStart = int(blobIndex[i] - 2);

      // scale from 0-1
      scale = (cos(blobAngle + blobOffsets[i]) + 1)/2.0;

      percent = blobIndex[i] - int(blobIndex[i]);

      // ends
      blobPixel(i, ledStart-1, scale * (1-percent));
      blobPixel(i, ledStart+1, scale * percent);

      // middle
      if (blobPixel(i, ledStart, scale)) {
        // back down to zero, generate new blob
        blobIndex[i] = 0;
        blobWaits[i] = random(10, 50);
      }
    }
  }
  strip.show();
}

bool blobPixel(unsigned int i, unsigned int blobLed, float percent) {
  unsigned int pixelColor, r, g, b;
  if (blobLed >= 0 && blobLed < LED_COUNT) {
    pixelColor = strip.getPixelColor(blobLed);
    r = pixelColor & 0x007f00;
    g = pixelColor & 0x7f0000;
    b = pixelColor & 0x00007f;
    r += byte(blobColors[3*i]   * percent) / 2;
    g += byte(blobColors[3*i+1] * percent) / 2;
    b += byte(blobColors[3*i+2] * percent) / 2;
    strip.setPixelColor(blobLed, r, g, b);
    return ( r == 0 && g == 0 && b == 0);
  }
}

void setWrap(int idx, int r, int g, int b) {
  int endIndex = idx;
  if (idx < 0) {
    endIndex = LED_COUNT + idx;
  } else if (idx > LED_COUNT - 1) {
    endIndex = idx - LED_COUNT;
  }
  strip.setPixelColor(endIndex, r, g, b);
}

const unsigned int chaseDelay = 70;
unsigned int chaseTimeout = 0;
unsigned int chaseState = 0;
void chase(unsigned long delta) {

  chaseTimeout += delta;
  if (chaseTimeout < chaseDelay) {
    return;
  }
  chaseTimeout -= chaseDelay;

  int i;

  // clear all the pixels
  for (i = 0; i < LED_COUNT; i++) {
    strip.setPixelColor(i, 0);
  }

  i = chaseState;
  setWrap(i-5, R/32, G/32, B/32);
  setWrap(i-4, R/16, G/16, B/16);
  setWrap(i-3, R/8,  G/8,  B/8);
  setWrap(i-2, R/4,  G/4,  B/4);
  setWrap(i-1, R/2,  G/2,  B/2);
  setWrap(i,   R,    G,    B);
  strip.show();

  chaseState = chaseState + 1;
  if (chaseState == LED_COUNT) {
    chaseState = 0;
  }
}

void clear() {
  for (unsigned int i=0; i < LED_COUNT; i++) {
    strip.setPixelColor(i, 0);
  }
  strip.show();
}

void setColorFromArgs() {
  for (uint8_t i=0; i<server.args(); i++){
    Serial.println(" NAME:"+server.argName(i) + "\n VALUE:" + server.arg(i));
  }
  if (server.hasArg("r")) {
    R = server.arg("r").toInt();
  }
  if (server.hasArg("g")) {
    G = server.arg("g").toInt();
  }
  if (server.hasArg("b")) {
    B = server.arg("b").toInt();
  }
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
