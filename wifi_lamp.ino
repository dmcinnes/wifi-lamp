#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include "LPD8806.h"
#include "wifi_creds.h"

ESP8266WebServer server(80);

#define LED_COUNT 16

#define DATA_PIN  0
#define CLOCK_PIN 2

unsigned long lastMillis;

LPD8806 strip = LPD8806(LED_COUNT, DATA_PIN, CLOCK_PIN);

void handle_root() {
  server.send(200, "text/plain", "hello from esp8266!");

  strip.setPixelColor(1, 1, 0, 0);
  strip.show();
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

  server.on("/", handle_root);

  server.on("/inline", [](){
    server.send(200, "text/plain", "this works as well");
  });

  server.begin();
  Serial.println("HTTP server started");

  strip.setPixelColor(0, 0, 0, 1);
  strip.show();

  lastMillis = millis();
  randomSeed(analogRead(0));
}

unsigned int bubbleUpdateOn[] = {0, 0, 0};
unsigned int bubbleTimers[]   = {0, 0, 0};
unsigned int bubbleLeds[]     = {0, 0, 0};
void bubble(unsigned long delta) {
  unsigned int i, led;

  for (i = 0; i < 3; i++) {
    if (bubbleUpdateOn[i] == 0) {
      bubbleUpdateOn[i] = random(30, 150);
    }

    bubbleTimers[i] += delta;

    if (bubbleTimers[i] > bubbleUpdateOn[i]) {
      bubbleTimers[i] -= bubbleUpdateOn[i];
      led = bubbleLeds[i];
      strip.setPixelColor(led, 0, 0, 0);
      led++;
      if (led < LED_COUNT) {
        strip.setPixelColor(led, 0, 0, 1);
        bubbleLeds[i] = led;
      } else {
        // reset
        bubbleLeds[i]     = 0;
        bubbleUpdateOn[i] = 0;
        bubbleTimers[i]   = 0;
      }
    }
  }
  strip.show();
}

void loop(void) {
  unsigned long currentMillis = millis();
  unsigned long delta = currentMillis - lastMillis;
  lastMillis = currentMillis;

  server.handleClient();

  bubble(delta);
}
