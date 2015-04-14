#include <ESP8266WiFi.h>
#include <WiFiClient.h>
#include <ESP8266WebServer.h>
#include "wifi_creds.h"

ESP8266WebServer server(80);

void OK() {
  server.send(200, "text/plain", "OK");
}

void setupServer() {
  server.on("/", []() {
    server.send(200, "text/plain", "Hello from esp8266!");
  });

  server.on("/bubble", HTTP_POST, [](){
    OK();
  });

  server.on("/rainbow", HTTP_POST, [](){
    OK();
  });
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
}

void loop(void) {
  server.handleClient();
}
