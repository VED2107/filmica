# Shader Notes — FILMICA

## Pipeline Architecture

### Preview Pipeline (Real-time, 60fps)
- Low-res textures
- Optimized shaders
- Runs on GPU via Flutter `FragmentProgram` API
- Target: 60fps on mid-range devices (Pixel 6a, iPhone 12 tier)

### Export Pipeline (Full-res, batch)
- Full resolution processing
- Maximum quality, no shortcuts
- Runs once on export (2-3s for 12MP)
- Progress indicator during processing

## Shader Stages (in order)

1. **Color adjustments** — Brightness, contrast, saturation, warmth
2. **Fade / lift blacks** — fadeAmount parameter
3. **Vignette** — vignetteStrength parameter
4. **Grain overlay** — grain parameter, noise texture
5. **LUT application** — If preset specifies a LUT asset
6. **Light leak / overlay** — overlayAsset + overlayOpacity

## Fallback Strategy

| Scenario | Behavior |
|----------|----------|
| Shader compiles successfully | Full GPU preview + GPU export |
| Shader fails to compile | Disable live preview effects, show simplified preview |
| Low-end device, shader too slow | Reduce preview resolution, maintain export quality |
| CPU fallback needed | Export-only processing, no live preview effects |

**Rule**: Always preserve full-quality export even if preview is degraded.

## Parameter Interpolation

All parameters interpolate linearly based on intensity slider (0.0 – 1.0):
- `intensity = 0.0` → Original image, no effect
- `intensity = 1.0` → Full preset effect

```
effectiveValue = originalValue + (presetValue - originalValue) * intensity
```

## GLSL Uniform Types

```glsl
uniform sampler2D uTexture;      // Input image
uniform float uBrightness;       // -1.0 to 1.0
uniform float uContrast;         // 0.0 to 2.0
uniform float uSaturation;       // 0.0 to 2.0
uniform float uWarmth;           // -1.0 to 1.0
uniform float uGrain;            // 0.0 to 1.0
uniform float uFadeAmount;       // 0.0 to 1.0
uniform float uVignetteStrength; // 0.0 to 1.0
uniform float uIntensity;        // 0.0 to 1.0 (master slider)
```

## Known Limitations

- Flutter `FragmentProgram` API is relatively new — test on multiple devices
- OpenGL ES 3.0 required — check device capabilities
- Precision qualifiers matter: use `mediump` for performance, `highp` for quality
- Grain texture should be pre-generated, not computed per-frame

## Performance Notes

- Keep shader complexity minimal for preview
- Use mipmapped textures for overlays
- Avoid texture reads in loops
- Profile on lowest-target device first

---

_Claude owns all shader implementation. Codex debugs shader issues when needed._
