#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uCandles[10];
uniform vec2 uSize;
uniform sampler2D uTexture;
uniform float uTime;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  // Base Shadow
  vec4 shadow = vec4(0.9, 0.9, 0.9, 0.0);

  // Candle Light
  float flicker = 0.8 + 0.1 * (
    sin(uTime * 5.0 + uv.x * 10.0) +
    sin(uTime * 6.0 + uv.x * 10.1) +
    sin(uTime * 9.0 + uv.x * 10.2) +
    sin(uTime * 10.0 + uv.x * 10.3) //+
    // sin(uTime * 20.0 + uv.x * 10.4) + 
    // sin(uTime * 100.0 + uv.x * 10.4)
  );
  vec4 candleLight = vec4(0.098, 0.2902, 0.4471, 0.0) * flicker;

  // apply shadow gradient
  for (int i = 0; i < 10; i++) {
    float distanceToCandle = distance(uv, uCandles[i]);

    shadow *= clamp(distanceToCandle/0.25, 0.0, 1.0);
  }

  // add candleLight
  shadow += candleLight;

  fragColor = texture(uTexture, uv) - shadow;
}
