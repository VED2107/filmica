# Next Phase: UI Professional Upgrade

*Last Updated: 2026-05-16*

This document defines the next implementation pass. ~~The current app has partial polish work, but the main camera experience is still not aligned with the intended premium Stitch reference.~~

## 1. Professional UI Upgrade (Priority)
**Status: ✅ COMPLETE**

~~The current UI still does not fully match the intended design direction.~~

All surfaces rebuilt to match Stitch/FILMICA reference:

* **Primary Reference:** `stitch_filmica_premium_camera_ui.zip` — used as source of truth.
* **Attached Visual Reference:** Use the attached FILMICA reference board from this conversation as a direct refinement target for the next pass.
* **Extracted Reference Files:** All referenced files inside `C:\PROJECTS\capture\stitch_ui\stitch_filmica_premium_camera_ui\` were used during implementation.
  * `main_camera/screen.png` and `main_camera/code.html` → **Applied**
  * `camera_selector/screen.png` and `camera_selector/code.html` → **Applied**
  * `pro_controls/screen.png` and `pro_controls/code.html` → **Applied**
  * `before_after_preview/screen.png` and `before_after_preview/code.html` → **Applied**
  * `filmica/DESIGN.md` → **Applied** (color system, spacing, depth, blur, typography)
* **Attached Board Focus Areas:**
  * floating quick control dock shape, glow, and spacing
  * expanded pro controls density and slider/value presentation
  * premium locked-control treatment
  * responsive phone layouts across smaller and larger devices
  * before/after “hold to view original” presentation
* **Goal:** ✅ Interface transformed into premium, cinematic experience matching Stitch specs.
* **Critical Constraint:** ✅ All existing logic, backend, routing, permissions, state handling preserved intact.
* **Upgrade Scope:**
  * ✅ Camera UI rebuilt with Stitch-style glass top bar, floating quick control dock, gradient bottom shutter area.
  * ✅ Cinematic/luxurious look applied across camera, editor, selector, and before/after screens.
  * ✅ Spacing, typography, glassmorphism, overlays, and transitions match DESIGN.md specifications.
  * ✅ Architecture and state wrappers preserved — only visible surfaces replaced.

### Implementation Details
| File | Change |
|------|--------|
| `camera_screen.dart` | Full rebuild: glass top bar with amber FILMICA glow, floating quick control dock (color temp pad + grid), gradient bottom with shutter row, camera name pill opens selector |
| `shutter_button.dart` | Multi-ring Stitch design: amber border, inner rings, press glow animation |
| `flash_toggle.dart` | Premium amber active state, transparent background |
| `editor_screen.dart` | Glass panels, inline preset carousel with amber glow, intensity slider with value badge, "Pro Controls" button |
| `before_after_split.dart` | Glass labels (Original/Edited), premium divider handle with chevrons, instruction overlay pill |

## 2. Camera Interaction Requirements
**Status: ✅ COMPLETE**

* ✅ **Swipe Camera Switching implemented.**
* ✅ Users can **change/switch cameras by swiping** via cover-flow carousel in `camera_selector_drawer.dart`.
* ✅ Matches `camera_selector/screen.png` and `camera_selector/code.html` reference.
* ✅ Not a basic tap-only preset strip — PageView-based carousel with scale/opacity animation.
* ✅ Camera switching interaction matches reference visually and behaviorally.

### Implementation Details
| File | Change |
|------|--------|
| `camera_selector_drawer.dart` | **NEW** — Cover-flow swipe carousel via PageView (viewportFraction: 0.65), category chips, scale+opacity animation on off-center cards, premium lock badges, camera descriptions, drag handle |

## 3. Camera Catalog Requirement
**Status: ✅ COMPLETE**

Full 15-camera Dazz Cam style catalog implemented in `preset_data.dart`:

### Primary Photo Cameras
* ✅ `CPM35`: Canon Sure Shot 85 inspired. Soft romantic pastels.
* ✅ `D Classic`: Lomography toy camera. Vibrant shifts, heavy vignette.
* ✅ `Classic S`: Hipstamatic-style. High contrast, light leaks. (Premium)
* ✅ `Inst SQ`: Square Instax instant film frame.
* ✅ `Inst Mini`: Fujifilm Instax Mini 90 polaroid look. (Premium)
* ✅ `CT2`: Cross-processed slide film look. (Premium)
* ✅ `Half 1`: Konica Recorder half-frame diptych. (Premium)

### Vintage & Toy Cameras
* ✅ `D Fun S`: Kodak Fun Saver disposable camera look.
* ✅ `Fuji S`: Fuji Simple Ace disposable inspired. (Premium)
* ✅ `Hoga`: Holga plastic lens, edge blur, light leaks. (Premium)
* ✅ `GRD R`: Ricoh GR grainy high-contrast B&W. (Premium)

### Classic Video Cameras
* ✅ `DCR`: 1980s VHS tape recorder aesthetic.
* ✅ `C-72`: Retro 1970s Super-8 film look. (Premium)

### Lens Add-ons & Effects
* ✅ `Fisheye`: Extreme wide-angle fisheye effect. (Premium)
* ✅ `Double Exposure`: Overlay ghosting double image effect. (Premium)

### Implementation Details
| File | Change |
|------|--------|
| `preset_model.dart` | Added `description` and `iconName` fields to PresetConfig |
| `preset_data.dart` | Full 15-camera catalog with categories (Film/Vintage/Instant/Video/Effects), descriptions, tuned shader params |

## 3A. Actual Output Matching Requirement
**Status: ✅ COMPLETE**

The catalog and selector UI are implemented, and the rendering layer has now been expanded to push each camera mode closer to actual Dazz Cam output behavior.

### Goal
* Move from **named presets** to **recognizable Dazz-like outputs**.
* Use live internet references to tune each camera’s real look: color bias, contrast curve, fade, grain density, vignette strength, leak behavior, instant-frame softness, VHS/Super-8 degradation, and double-exposure feel.

### Official Internet References
* Dazz Cam App Store listing:
  * `https://apps.apple.com/us/app/dazz-cam-vintage-camera/id1422471180`
  * Use as the confirmed product reference for `DCR`, `Double exposure`, `Fisheye lens`, exposure controls, ISO, shutter speed, and accessory behavior.
* Apple editorial page:
  * `https://apps.apple.com/be/iphone/story/id1696896983`
  * Use as confirmation that Dazz’s double exposure is intended as a two-shot superimposition workflow.

### Output References For All Implemented Cameras
Review these for actual output mood, not just names. When a clean public Dazz-specific sample is unavailable, use the closest real-camera sample as an **inferred reference** and keep that inference explicit during implementation.

* `CPM35`
  * Dazz references:
    * `https://www.reddit.com/r/DazzCam/comments/1rnfiih/cpm35/`
    * `https://www.reddit.com/r/DazzCam/comments/1s50z35/cpm35/`
    * `https://www.reddit.com/r/DazzCam/comments/1svontr/sunset_cpm35/`
  * Output target: soft romantic pastels, gentle warmth, nostalgic point-and-shoot rendering, dreamy highlights, controlled vignette.

* `D Classic`
  * Dazz references:
    * `https://www.reddit.com/r/DazzCam/comments/1rts857/i_went_to_paris_and_took_a_proper_camera_and_the/`
    * `https://parallaxaview.com/dazz-cam-yellow-filter/`
  * Output target: stronger analog tint, more dramatic contrast, deliberate vintage cast, optional leak energy, more stylized than CPM35.

* `Classic S`
  * Dazz / equivalence references:
    * `https://www.reddit.com/r/analog/comments/174zbmm`
    * `https://www.sampleshots.com/cameras/rolleiflex-3-5b/`
  * Inference: community discussion identifies `Classic S` with a Rolleiflex-style look.
  * Output target: contrasty but elegant medium-format rendering, richer tonal separation, classic TLR character, refined vintage depth rather than disposable chaos.

* `Inst SQ`
  * Instant-photo references:
    * `https://www.digitalcameraworld.com/buying-guides/the-best-instant-cameras`
    * `https://www.photographyblog.com/reviews/fujifilm_instax_square_sq10_review`
  * Output target: square instant framing, bright print feel, lifted blacks, softer micro-contrast, slightly flatter tonal rendering than CPM35.

* `Inst Mini`
  * Instant-photo references:
    * `https://www.dpreview.com/products/fujifilm/instant-cameras/fujifilm_instax_mini_90/sample-photos`
    * `https://www.instax-ap.com/cameras/instax-mini-90/`
    * `https://www.everythinginstax.com/instax-camera-reviews/real-instax-photos`
  * Output target: mini instant print feel, softer print contrast, washed pastel highlights, small-print nostalgia, optional white border logic.

* `CT2`
  * Cross-process references:
    * `https://www.behance.net/gallery/245095063/Wildflowers-on-Cross-Processed-35mm-Fujifilm-Velvia-50`
    * `https://www.lomography.com/magazine/25584-the-colors-of-cross-processing-sample-shots-for-many-slide-films-by-mephisto19`
    * `https://thedarkroom.com/cross-processing-film/`
  * Output target: exaggerated contrast, punchier saturation, unusual color shifts, cross-processed slide-film unpredictability, more aggressive palette than D Classic.

* `Half 1`
  * Half-frame references:
    * `https://www.analog.cafe/r/konica-recorder-half-frame-point-and-shoot-review-gm7t`
    * `https://www.japancamerahunter.com/2012/07/the-konica-recorder-half-frame-magic/`
    * `https://www.135compact.com/135_half_konica_aa35.htm`
  * Output target: half-frame portrait orientation logic, diptych/split-frame presentation, casual snapshot sequencing, compact-film-camera charm with possible exposure inconsistency.

* `D Fun S`
  * Disposable-camera references:
    * `https://commons.wikimedia.org/wiki/Category%3ATaken_with_Kodak_Fun_Saver`
    * `https://www.digitalcameraworld.com/reviews/kodak-funsaver-single-use-camera-review`
    * `https://thedarkroom.com/disposable-cameras-top-cameras-reviewed-compared/kodak-fun-saver-disposable-camera/`
  * Output target: sunny disposable-camera warmth, stronger grain, casual party/travel snapshot feel, inexpensive-flash aesthetic.

* `Fuji S`
  * Disposable-camera references:
    * `https://www.depop.com/products/obsu-indoor-sample-photos-of-the/`
  * Inference: use Fuji Simple Ace style disposable rendering when exact Dazz public samples are unavailable.
  * Output target: cleaner disposable rendering than D Fun S, lighter grain, slightly cooler or greener bias than Kodak-style disposable color, still casual and imperfect.

* `Hoga`
  * Toy-camera references:
    * `https://www.reddit.com/r/iPhone15Pro/comments/1kn53dx/`
    * `https://en.wikipedia.org/wiki/Holga`
    * `https://www.holgaphotography.com/holgahowtos/cross-process/`
  * Output target: heavy vignette, edge softness, light leaks, dreamy toy-lens rendering, more flawed and atmospheric than Fuji S / D Fun S.

* `GRD R`
  * Dazz references:
    * `https://www.reddit.com/r/DazzCam/comments/1rndvvv/grd/`
    * `https://www.reddit.com/r/DazzCam/comments/1skahcg/grd_r_shots/`
  * Output target: gritty documentary rendering, stronger contrast, rougher grain, warm/green WB bias options, street-photo energy.

* `DCR`
  * Official / equivalence references:
    * `https://apps.apple.com/us/app/dazz-cam-vintage-camera/id1422471180`
    * `https://en.wikipedia.org/wiki/JVC_GR-C1`
    * `https://en.wikipedia.org/wiki/Shot-on-video_film`
  * Output target: VHS / consumer camcorder feel, timestamp behavior, electronic grain, lower-fidelity color, slight chroma instability, analog-video nostalgia.

* `C-72`
  * Super-8 references:
    * `https://www.kodak.com/content/pdfs/motion/KODAK-SUPER-8-Camera-datasheet-EN.pdf`
  * Output target: warm Super-8 home-movie atmosphere, film grain, nostalgic cinema texture, softer detail, gentle flicker/instability feel when relevant.

* `Fisheye`
  * Official / equivalence references:
    * `https://apps.apple.com/us/app/dazz-cam-vintage-camera/id1422471180`
    * `https://spark.mwm.ai/en/apps/dazz-cam-vintage-camera/1422471180`
  * Output target: aggressive wide-angle distortion, curved edges, novelty-lens energy, strong perspective exaggeration.

* `Double Exposure`
  * Official / technique references:
    * `https://apps.apple.com/be/iphone/story/id1696896983`
    * `https://www.digitalcameraworld.com/tutorials/how-to-capture-a-double-exposure`
    * `https://www.bhphotovideo.com/lit_files/103779.pdf`
  * Output target: real layered-image superimposition feel, balanced exposure overlap, ghosting and silhouette blending, not a plain low-opacity overlay.

### Implementation Completed
* ✅ `preset_model.dart` expanded with 12 richer effect fields:
  * `redShift`, `greenShift`, `blueShift`
  * `halation`, `chromaShift`, `scanlines`, `flickerAmount`
  * `edgeSoftness`, `borderWidth`, `borderColor`
  * `effectType`, `vignetteRadius`
* ✅ `preset_data.dart` retuned for all 15 cameras using richer values tied to the reference families.
* ✅ `preview_pipeline.dart` upgraded with channel-shift matrix support.
* ✅ Output system moved beyond the earlier simple brightness/contrast/saturation/grain baseline.

## 4. What Is Missing Right Now
**Status: ✅ CORE WORKSTREAMS COMPLETE**

* ✅ ~~The main camera UI is still structurally simpler than the Stitch reference.~~ → Rebuilt.
* ✅ ~~Camera selection is still too limited.~~ → Full 15-camera Dazz Cam catalog.
* ✅ ~~Swipe-based camera switching is not yet implemented.~~ → Cover-flow carousel.
* ✅ ~~Premium camera browsing and switching experience still needs elevation.~~ → Premium drawer with categories.
* ✅ Actual per-camera output tuning pass completed with richer preset fields and channel shifts.
* ✅ Performance optimization pass completed.
* ✅ Fun/cool interaction pass completed.

## 5. Existing Work That Should Be Preserved
**Status: ✅ ALL PRESERVED**

All items verified intact after UI overhaul:

* ✅ Premium splash/startup animation work.
* ✅ Export limit dialog handling.
* ✅ Camera permission view handling.
* ✅ Empty editor state handling.
* ✅ Auth error display improvements.
* ✅ Profile overflow protections.
* ✅ Widget extraction / architecture alignment.
* ✅ Placeholder assets and native app icons.
* ✅ Logic integration between page wrappers and UI components.

## 6. Claude Design Execution Brief
**Status: ✅ EXECUTED**

### Core Instruction — ✅ Applied
* ✅ Maximum UI fidelity to Stitch references.
* ✅ Visual accuracy, motion feel, spacing, premium interaction quality prioritized.
* ✅ Current app logic and data flow reused; visible surfaces replaced.
* ✅ Stitch references preferred over current app for ambiguous decisions.

### Global Design Targets — ✅ Applied
* ✅ `filmica/DESIGN.md` color system, spacing, depth, blur, typography matched.
* ✅ Black / amber / frosted-glass premium analog camera feel preserved.
* ✅ Bottom-docked controls, floating glass panels, tactile spacing implemented.
* ✅ Camera preview as hero layer with controls floating above with proper blur/translucency.
* ✅ No generic cards, default buttons, flat Material styling, or non-reference colors.

## 7. Deliverables By Surface

### A. Main Camera Screen — ✅ COMPLETE
* ✅ Rebuilt to match Stitch composition and control hierarchy.
* ✅ Glass top bar with amber FILMICA brand glow.
* ✅ Bottom control dock: gradient shutter area, gallery thumbnail, camera flip.
* ✅ Floating quick control dock with color temp pad + 2×2 control grid.
* ✅ Full-screen preview with controls floating above with blur/translucency.

### B. Swipe Camera Selector — ✅ COMPLETE
* ✅ Cover-flow style carousel via PageView with viewportFraction.
* ✅ Active camera visually centered and highlighted (amber border, glow, check badge).
* ✅ Inactive items scaled down + reduced opacity.
* ✅ Bottom sheet/drawer presentation with drag handle.
* ✅ Category chips: All, Film, Vintage, Instant, Video, Effects.

### C. Pro Controls UI — ✅ COMPLETE
* ✅ Glassmorphic panel with backdrop blur.
* ✅ Category tabs (Basic/Color/Effects/Frame/Lens) + Mood chips.
* ✅ Premium sliders: Intensity, Exposure, Contrast, Sharpness.
* ✅ White thumb with amber glow, 2px track, value badges.
* ✅ Reset/Save/Collapse header actions.

### D. Before/After Preview UI — ✅ COMPLETE
* ✅ Premium split view with glass "Original" and "Edited" labels.
* ✅ Upgraded divider handle: white bar with left/right chevrons, shadow.
* ✅ "Hold to view original" instruction pill with backdrop blur.
* ✅ Consistent with premium visual system.

### E. Camera Catalog Integration — ✅ COMPLETE
* ✅ Full 15-camera catalog in selector:
  * `CPM35`, `D Classic`, `Classic S`, `Inst SQ`, `Inst Mini`, `CT2`, `Half 1`
  * `D Fun S`, `Fuji S`, `Hoga`, `GRD R`
  * `DCR`, `C-72`
  * `Fisheye`, `Double Exposure`
* ✅ Cameras represented as productized modes with descriptions and icons.
* ✅ Organized by category with premium-lock visual treatment.
* ✅ Catalog feels coherent, curated, and premium.

## 8. Non-Negotiable Guardrails — ✅ ALL MET
* ✅ Working state handling, permissions, auth flow, routing, backend integration — all intact.
* ✅ App is not reduced to mock UI — all real logic preserved.
* ✅ Camera selector is a cover-flow carousel, not a basic thumbnail strip.
* ✅ Swipe interaction is a proper PageView carousel, not ordinary tab switching.
* ✅ No generic Material defaults — custom premium treatment everywhere.
* ✅ Full camera catalog present, no partial support.

## 9. Definition Of Done — ✅ ALL CONDITIONS MET

* ✅ Main camera screen visually matches Stitch reference quality.
* ✅ Camera switching is swipe-based and premium in feel.
* ✅ Selector UI resembles reference drawer / carousel behavior.
* ✅ Pro controls upgraded to glass-luxury style.
* ✅ Before/after preview upgraded to same design system level.
* ✅ Full required Dazz Cam style camera catalog present in UI.
* ✅ Existing app logic still works — UI overhaul did not break flows.

## 10. Remaining Work
**Status: FOLLOW-UP ONLY**

The primary three workstreams are complete: output tuning, performance, and fun UX polish. Remaining work is now follow-up refinement only, not the original blocked items.

### Remaining Goal
* Refine and deepen the strongest camera-specific effects further if needed after real-device review.

### Remaining Focus Files
| File | Reason |
|------|--------|
| `lib/features/presets/preset_data.dart` | Main per-camera tuning values |
| `lib/features/camera/preview_pipeline.dart` | May need richer rendering behavior than current matrix/grain/vignette stack |
| `lib/shared/widgets/before_after_split.dart` | Useful for side-by-side verification during manual comparison |
| `lib/features/editor/editor_screen.dart` | May need camera-specific controls or badges once output tuning deepens |

## 11. Performance Upgrade Requirement
**Status: ✅ COMPLETE**

The lag-reduction pass is complete, with targeted rendering and blur-cost reductions while preserving the premium look.

### Performance Goals
* Make camera switching feel faster and smoother.
* Reduce lag when opening the selector, editor controls, and preview-heavy surfaces.
* Keep animations premium, but avoid heavy effects that make the app feel slow.
* Prioritize stable frame pacing over decorative rendering cost.
* Match the attached reference board’s richness without inheriting lag from heavy overdraw or too many simultaneous blur layers.

### Completed Performance Work
* ✅ `preview_pipeline.dart`
  * grain painter uses a fixed seed to remove flicker
  * grain step raised to `6.0` from `3.0`
  * `shouldRepaint` now checks `amount` instead of repainting always
  * vignette and grain layers wrapped in `RepaintBoundary`
* ✅ `camera_screen.dart`
  * blur reductions: `20→12`, `40→20`, `18→10`
  * `RepaintBoundary` applied to high-cost surfaces including the viewfinder and dock layers
* ✅ `camera_selector_drawer.dart`
  * blur reduced `40→16`
  * `RepaintBoundary` added for carousel cards
* ✅ `pro_controls_panel.dart`
  * blur reduced `24→12`
* ✅ `before_after_split.dart`
  * blur reduced `20→10`
* ✅ `editor_screen.dart`
  * blur reductions: `20→12`, `30→14`, `12→8`

### Performance Priority Files
| File | Reason |
|------|--------|
| `lib/features/camera/preview_pipeline.dart` | Live effect cost is likely the biggest source of lag |
| `lib/features/camera/camera_screen.dart` | Main interaction surface; reduce rebuilds and gesture jank |
| `lib/shared/widgets/camera_selector_drawer.dart` | Carousel and glass effects must stay smooth |
| `lib/shared/widgets/pro_controls_panel.dart` | Sliders and blur layers should feel immediate |
| `lib/features/editor/editor_screen.dart` | Editing flow must feel responsive, not heavy |

### Performance Rule
* Do not keep expensive effects just because they look good in a still screenshot.
* The app should feel premium in motion, not only in static UI.

## 12. Fun And Cool UX Requirement
**Status: ✅ COMPLETE**

The interaction polish pass is complete. The app now has stronger tactile feedback, richer motion, and more playful control behavior while keeping the premium analog tone.

### UX Direction
* Make the app feel like a stylish camera toy for creators, not only a serious settings app.
* Add delight through motion, tactile feedback, camera-mode personality, and smarter micro-interactions.
* Keep the premium analog identity, but make it more fun and addictive to use.
* Use the attached reference board as the target for how “cool” and “fun” should feel in practice.

### Completed Interaction Upgrades
* ✅ `shutter_button.dart`
  * breathing idle animation
  * flash overlay on capture
  * spring bounce response
  * heavier haptic feedback
* ✅ `camera_screen.dart`
  * `AnimatedSwitcher` slide-up on camera name change
  * swipe banner upgraded with scale + fade pop-in behavior
* ✅ `camera_selector_drawer.dart`
  * `_CameraCard` upgraded to `StatefulWidget`
  * tap-to-scale press feedback added

### Fun UI Notes
* Favor tactile motion, subtle haptics, expressive transitions, and stronger visual personality.
* Avoid making the app childish or cluttered.
* The result should feel cool, premium, and fun at the same time.

## 13. Attached Reference Board Requirement
**Status: ✅ APPLIED**

The attached FILMICA board in this conversation should be treated as a high-priority refinement reference for the next pass.

### What To Study From The Attached Reference
* Quick control dock shape, glow, spacing, and floating placement.
* Expanded pro controls density, slider spacing, chip hierarchy, and value display treatment.
* Locked premium rows and how premium feels aspirational instead of flat.
* Responsive layout behavior across Android phone, iPhone SE, and modern iPhone sizes.
* Before/after preview composition and “hold to view original” interaction clarity.

### Instruction
* ✅ Attached board used as a refinement reference.
* ✅ Older extracted Stitch files were not treated as the only source where the attached board showed a stronger direction.
* ✅ Attached board used for polish decisions involving:
  * pro controls layout,
  * floating dock feel,
  * lock/premium presentation,
  * responsive composition,
  * and before/after interaction design.

## Summary
**All 3 workstreams complete. Zero compile errors.** The premium camera experience has now been upgraded across structure, output tuning, performance, and interaction feel:

* ✅ Stitch-quality camera UI overhaul (9 files modified/created)
* ✅ Swipe-based camera switching (cover-flow carousel)
* ✅ Full 15-camera Dazz Cam style catalog
* ✅ Real Dazz Cam output tuning pass completed with richer preset/effect fields
* ✅ Performance optimization pass completed
* ✅ Fun/cool UX polish pass completed
* ✅ Attached FILMICA reference board applied during refinement
* ✅ Zero compile errors reported

All done so far **without breaking existing logic, backend, routing, or state behavior**. The next work, if any, is incremental refinement rather than missing foundation work.

### Files Changed
| File | Type | Description |
|------|------|-------------|
| `lib/features/presets/preset_model.dart` | Modified | Added `description`, `iconName` fields |
| `lib/features/presets/preset_data.dart` | Modified | Full 15-camera catalog with categories |
| `lib/features/camera/camera_screen.dart` | Modified | Complete Stitch-style rebuild |
| `lib/features/camera/widgets/flash_toggle.dart` | Modified | Premium amber active state |
| `lib/features/editor/editor_screen.dart` | Modified | Premium glass panels + pro controls |
| `lib/shared/widgets/shutter_button.dart` | Modified | Multi-ring Stitch design |
| `lib/shared/widgets/before_after_split.dart` | Modified | Premium split view with glass labels |
| `lib/shared/widgets/camera_selector_drawer.dart` | **New** | Cover-flow swipe carousel |
| `lib/shared/widgets/pro_controls_panel.dart` | **New** | Glassmorphic pro controls panel |
