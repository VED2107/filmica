# UI References — FILMICA

## Design Source: Stitch

All UI references are pulled directly from Stitch. No external app references.

**Stitch API Key:** `REDACTED`

**Gemini Extension:**
```
gemini extensions install https://github.com/gemini-cli-extensions/stitch
```

Stitch designs are the **single source of truth** for:
- Layout structure
- Spacing
- Component proportions
- Visual hierarchy
- Motion style
- Color decisions

## Design Philosophy

FILMICA should feel like a premium analog camera system where:
- Selecting a camera feels like **switching lenses**.
- Tuning controls feels like **adjusting physical dials**.
- Every interaction feels **luxurious**.
- The app is clearly **more sophisticated and more polished** than Dazz Cam.

## Key Visual Principles

### Camera Screen
- Dark viewfinder, full edge-to-edge preview
- Translucent top bar with amber glow logo
- Camera selector with cover flow carousel
- Quick control dock with color pad
- Large, tactile shutter button centered at bottom

### Editor / Pro Controls
- Full-screen image preview
- Expandable pro controls panel with blur backdrop
- Custom sliders with animated numeric values
- Quick mood chips for preset tuning
- Before/after via long-press with label overlays

### Paywall
- Bottom sheet with spring animation
- Hero before/after comparison
- Individual preset buy option + full subscription
- Gold shimmer on locked controls

### Onboarding
- Full-bleed hero images
- Minimal text, high impact visuals
- FILMICA logo with amber glow on launch

## Animation Reference

All animation specs are defined in `AGENT_GEMINI_Workflow.md` Section 5 (FILMICA Animation Specification).

Key animations:
- 17 distinct animation sequences
- All spring-based, under 500ms
- Apple-style motion feel
- Ambient amber glow as signature micro-interaction

## Micro-Interactions

| Element | Effect |
|---------|--------|
| Active controls | Ambient amber glow |
| Button taps | Haptic + subtle scale |
| State changes | Soft shadow depth shift |
| Numeric values | Animated number transition |
| Filter switch | Preview crossfade |
| Touch response | Subtle ripple |

---

_Gemini pulls all design references from Stitch. Do not reference external apps._
