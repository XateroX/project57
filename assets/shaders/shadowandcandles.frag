#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

const int MAX_CANDLES = 16;
uniform float uNumCandles;
uniform vec2 uCandles[MAX_CANDLES];
uniform vec2 uSize;
uniform sampler2D uTexture;
uniform float uTime;

out vec4 fragColor;

void main() {
  int count = int(uNumCandles + 0.5);  // round to nearest integer

  vec2 uv = FlutterFragCoord().xy / uSize;
  // // Base Shadow
  vec4 shadow = vec4(0.9, 0.9, 0.9, 0.0);

  // // Candle Light
  float flicker = 0.8 + 0.1 * (
    sin(uTime * 5.0 + uv.x * 10.0) +
    sin(uTime * 6.0 + uv.x * 10.1) +
    sin(uTime * 9.0 + uv.x * 10.2) +
    sin(uTime * 10.0 + uv.x * 10.3) +
    sin(uTime * 20.0 + uv.x * 10.4) + 
    sin(uTime * 100.0 + uv.x * 10.4)
  );
  vec4 candleLight = vec4(0.05, 0.1502, 0.2271, 0.0) * flicker;

  // apply shadow gradient
  for (int i = 0; i < MAX_CANDLES; i++) {  // MAX_CANDLES is a constant :contentReference[oaicite:6]{index=6}
    if (i >= count) {
      break;                              // early exit for unused slots
    }
    vec2 aspect = vec2(uSize.x / uSize.y, 1.0);
    float distanceToCandle = length((uv - uCandles[i]) * aspect);

    shadow *= clamp(distanceToCandle/0.45, 0.0, 1.0);
  }

  // add candleLight
  shadow += candleLight;

  fragColor = texture(uTexture, uv) - shadow;
}
