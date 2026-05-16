# Store Submission Checklist — FILMICA

## App Store (iOS)

### App Store Connect Setup
- [ ] Apple Developer account active
- [ ] App ID registered (com.filmica.app)
- [ ] App Store Connect app record created
- [ ] Bundle ID matches project config

### Required Metadata
- [ ] App name (30 chars max)
- [ ] Subtitle (30 chars max)
- [ ] Description (up to 4000 chars)
- [ ] Keywords (100 chars max, comma-separated)
- [ ] Primary category: Photo & Video
- [ ] Content rating questionnaire completed
- [ ] Copyright notice

### Required Assets
- [ ] App icon (1024x1024, no alpha, no rounded corners)
- [ ] Screenshots — iPhone 6.7" (1290x2796) — minimum 3
- [ ] Screenshots — iPhone 6.5" (1242x2688) — minimum 3
- [ ] Screenshots — iPhone 5.5" (1242x2208) — minimum 3
- [ ] App preview video (optional but recommended)
- [ ] Feature graphic (optional)

### Compliance
- [ ] Privacy Policy URL provided
- [ ] Terms of Service URL provided
- [ ] App Privacy (nutrition labels) completed
- [ ] Camera usage description in Info.plist
- [ ] Photo library usage description in Info.plist
- [ ] App Tracking Transparency (ATT) implemented
- [ ] Account deletion available in-app
- [ ] IDFA usage declared correctly

### In-App Purchases
- [ ] Monthly subscription ($3.99) created in App Store Connect
- [ ] Yearly subscription ($19.99) created
- [ ] Lifetime purchase ($49.99) created
- [ ] 3-day free trial configured on yearly plan
- [ ] Review notes for IAP submitted
- [ ] Subscription group created
- [ ] Promotional offers configured (if any)

### Build & Release
- [ ] Production certificate and provisioning profile ready
- [ ] Codemagic builds IPA successfully
- [ ] Build uploaded to App Store Connect
- [ ] TestFlight testing completed on physical device
- [ ] Version number and build number set
- [ ] Release notes written

### Review Preparation
- [ ] Demo account credentials (if needed)
- [ ] Review notes explaining app functionality
- [ ] All placeholder content removed
- [ ] No broken links or placeholder URLs
- [ ] App works fully for reviewer (even without purchase)

---

## Google Play Store (Android)

### Play Console Setup
- [ ] Google Play Developer account active
- [ ] App record created
- [ ] Package name matches: com.filmica.app

### Required Metadata
- [ ] App title (50 chars max)
- [ ] Short description (80 chars max)
- [ ] Full description (4000 chars max)
- [ ] Primary category: Photography
- [ ] Content rating questionnaire completed
- [ ] Contact email provided

### Required Assets
- [ ] App icon (512x512 PNG)
- [ ] Feature graphic (1024x500 PNG)
- [ ] Screenshots — Phone (min 2, max 8)
- [ ] Screenshots — 7" tablet (optional)
- [ ] Screenshots — 10" tablet (optional)
- [ ] Promo video (YouTube URL, optional)

### Compliance
- [ ] Privacy Policy URL provided
- [ ] Data safety form completed
- [ ] Camera permission justification
- [ ] Storage permission justification
- [ ] Ads declaration (no ads for MVP)
- [ ] Target audience and content set
- [ ] Account deletion available

### In-App Purchases
- [ ] Products created in Play Console
- [ ] Subscription products configured
- [ ] Licensing testing accounts added
- [ ] Revenue sharing acknowledged

### Build & Release
- [ ] Signing key created and stored securely
- [ ] AAB built successfully
- [ ] Internal testing track upload
- [ ] Internal testing completed
- [ ] Promoted to production track
- [ ] Release notes written
- [ ] Staged rollout percentage set (start at 20%)

---

## Pre-Submission Final Check

- [ ] App cold starts in < 2s
- [ ] No crashes during normal usage
- [ ] All features work as described in store listing
- [ ] In-app purchases complete successfully
- [ ] Account deletion works end-to-end
- [ ] Privacy Policy is accessible from within the app
- [ ] All analytics events firing correctly
- [ ] Crashlytics receiving test crash reports
