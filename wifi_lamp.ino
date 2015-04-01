#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include "LPD8806.h"
#include "wifi_creds.h"

ESP8266WebServer server(80);

#define LED_COUNT 16

#define DATA_PIN  0
#define CLOCK_PIN 2

LPD8806 strip = LPD8806(LED_COUNT, DATA_PIN, CLOCK_PIN);

void handle_root() {
  server.send(200, "text/plain", "hello from esp8266!");

  strip.setPixelColor(1, 1, 0, 0);
  strip.show();
}

void setup(void) {
  strip.begin();

  strip.show();

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

  server.on("/", handle_root);

  server.on("/inline", [](){
    server.send(200, "text/plain", "this works as well");
  });

  server.begin();
  Serial.println("HTTP server started");

  strip.setPixelColor(0, 0, 0, 1);
  strip.show();
}

void loop(void) {
  server.handleClient();
}
