#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include "wifi_creds.h"

#define DATA_PIN  0
#define CLOCK_PIN 2


uint8_t  nextChar  = 0x80;
uint16_t spiBuffer = 0x8080;
uint16_t spiBit    = 0x8000;


ESP8266WebServer server(80);

void OK() {
  server.send(200, "text/plain", "OK");
}

void setupServer() {
  server.on("/", []() {
    server.send(200, "text/plain", "Hello from esp8266!");
  });

  server.on("/bubble", HTTP_POST, [](){
    nextChar = 'B';
    OK();
  });

  server.on("/rainbow", HTTP_POST, [](){
    nextChar = 'R';
    OK();
  });
}

void spiClock() {
  if (digitalRead(CLOCK_PIN) == HIGH) {
    if (spiBuffer & spiBit) {
      digitalWrite(DATA_PIN, HIGH);
    } else {
      digitalWrite(DATA_PIN, LOW);
    }

    if (spiBit > 0x00) {
      spiBit >>= 1;
    } else {
      if (nextChar != 0x80) {
        spiBuffer = nextChar;
      } else {
        spiBuffer = 0x8080;
      }
      nextChar = 0x80;
    }
  }
}

void setup(void) {
  Serial.begin(115200);

  // Connect to WiFi network
  WiFi.begin(WLAN_SSID, WLAN_PASS);
  Serial.println("");

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

  // let the attiny85 drive the clock
  pinMode(CLOCK_PIN, INPUT);
  pinMode(DATA_PIN, OUTPUT);

  attachInterrupt(CLOCK_PIN, spiClock, CHANGE);
}

void loop(void) {
  server.handleClient();
}
