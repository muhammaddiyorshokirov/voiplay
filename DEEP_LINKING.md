# Deep linking (uni_links)

✅ **Updated dependency:** `uni_links: ^0.5.1` (Dec 2025 compatible; note: package marked discontinued on pub.dev and replaced by `app_links`, but `uni_links` v0.5.1 is still usable)

## What I changed
- Replaced `app_links: ^6.3.2` with `uni_links: ^0.5.1` in `pubspec.yaml`.
- Ran `flutter pub get` and `flutter analyze` — no static issues found.

## How deep links are handled in the app
- `lib/main.dart` uses:
  - `final initialUri = await getInitialUri();` to handle cold-start links.
  - `uriLinkStream` to listen for links when the app is resumed.
- The `_handleUri(Uri uri)` method routes to screens based on `uri.pathSegments` (e.g. `/news/123`, `/anime/456`, `/episode/789`).

## Platform configuration in this project
### Android (`android/app/src/main/AndroidManifest.xml`)
- Intent filters already exist for:
  - `https` host `app.voiplay.uz` (autoVerify=true)
  - `https` host `link.voiplay` (autoVerify=true)
  - Custom scheme `uz.voiplay.tv`

You can test links with adb, e.g.:
```bash
adb shell 'am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "uz.voiplay.tv://news/123"'
adb shell 'am start -a android.intent.action.VIEW -c android.intent.category.BROWSABLE -d "https://link.voiplay/news/123"'
```

### iOS (`ios/Runner/Info.plist`)
- `CFBundleURLTypes` contains URL schemes `voiplay` and `uz.voiplay.tv`.
- For Universal Links (`https`) you must add `com.apple.developer.associated-domains` in `Runner.entitlements` and enable Associated Domains capability in Xcode; add `applinks:your_host_here`.

Test on iOS simulator:
```bash
xcrun simctl openurl booted "uz.voiplay.tv://news/123"
xcrun simctl openurl booted "https://link.voiplay/news/123"
```

## Notes & recommendation
- `uni_links` is marked discontinued on pub.dev and the author recommends `app_links` as the replacement. If you prefer a maintained package, consider migrating to `app_links` and I'll prepare the migration steps.
- If you want, I can also add automated tests or an example screen to verify incoming links during development.

---
If you want me to migrate to `app_links` instead (recommended long-term), tell me and I'll implement the migration and adjust the code accordingly. 🎯