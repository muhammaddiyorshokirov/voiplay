# Gradle Play Publisher (GPP) — Quick setup for this project

Steps to use GPP for automatic uploads (mapping & native symbols are included when present):

1. Upload the first App Bundle manually to Play Console (initial registration required).
2. Create a Google Cloud Service Account and download the JSON key. Enable the Android Publisher API.
3. Place the JSON file at the project root and name it `play-service-account.json` (or set the contents into the `ANDROID_PUBLISHER_CREDENTIALS` environment variable — this is safer).

Example commands:
- Validate setup: `./gradlew bootstrapListing`
- Publish an App Bundle to the internal track: `./gradlew publishBundle`
- Or publish and upload to internal track explicitly: `./gradlew publishBundle --track internal`

Notes:
- GPP will default to App Bundles if `defaultToAppBundles` is set (configured in `app/build.gradle.kts`).
- Mapping for AABs is contained in the bundle; native debug symbols are created when `ndk.debugSymbolLevel = "FULL"` and are kept by `packaging.jniLibs.keepDebugSymbols = true` (already configured in this repo).
- Do NOT commit your service account JSON to source control. Use the `ANDROID_PUBLISHER_CREDENTIALS` env var or keep the file locally and ensure `.gitignore` contains `play-service-account.json`.

Tip: A safe example template is provided at the project root as `play-service-account.json.example`. Copy the real JSON you download from Google Cloud Console into `play-service-account.json` (do not commit it).
