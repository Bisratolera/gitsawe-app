# Releasing Gitsawe

## One-time setup

### 1. Choose the application id
`com.gitsawe.app` is set in `android/app/build.gradle.kts` (`applicationId` and `namespace`).
**It can never change after the first Play upload.** If you want a different id, change it now
in that file, in `android/app/src/main/kotlin/<package path>/MainActivity.kt`, in
`lib/main.dart` (audio channel id) and in `.github/workflows/release.yml` (`packageName`).

### 2. Create the upload key
```bash
./tools/create_keystore.sh          # needs JDK's keytool
```
Keep `upload-keystore.jks` and both passwords somewhere safe. Never commit them.

### 3. Add GitHub secrets
Repository → Settings → Secrets and variables → Actions:

| Secret | Value |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | `base64 -w0 upload-keystore.jks` |
| `ANDROID_KEYSTORE_PASSWORD` | store password |
| `ANDROID_KEY_ALIAS` | `upload` (or what you chose) |
| `ANDROID_KEY_PASSWORD` | key password |
| `PLAY_SERVICE_ACCOUNT_JSON` | _(optional)_ Play API service-account JSON, for automatic uploads |

### 4. Google Play Console
1. Create the app (Play Console → Create app), pay the one-time developer fee if you have not.
2. Enable **Play App Signing** (default) and upload your first `.aab` **manually** to the Internal testing track
   (Google does not allow the API to create the very first release).
3. Complete the store listing using `docs/play-store/listing.md` and graphics in that folder.
   Add 2–8 phone screenshots (take them from a real device or emulator).
4. Fill in: Privacy policy URL (`https://github.com/Bisratolera/gitsawe-app/blob/main/PRIVACY_POLICY.md`),
   Data safety, Content rating, Target audience, Ads (= No). Answers are in `listing.md`.
5. For a new personal developer account Google requires a closed test with 12+ testers for 14 days before
   production access – check the current rules in Play Console.
6. _(Optional)_ To enable automatic uploads, create a service account in Google Cloud, grant it
   access in Play Console → Users and permissions, and save its JSON key as `PLAY_SERVICE_ACCOUNT_JSON`.

## Making a release

1. Update `version:` in `pubspec.yaml` **and** `lib/core/app_info.dart` (a unit test checks they match), and `CHANGELOG.md`.
2. Commit, then:
   ```bash
   git tag v1.0.0
   git push origin main --tags
   ```
3. The **Release** workflow builds, signs and tests, then publishes a GitHub Release containing
   `gitsawe-<version>.aab`, universal + per-ABI APKs and `SHA256SUMS.txt`, and (if configured)
   uploads the bundle to Play as a **draft** on the Internal track. Promote it in Play Console.

The Play `versionCode` is the workflow run number, so it always increases.

## Local signed build
Create `android/key.properties` (see the output of `create_keystore.sh`), then
`flutter build appbundle --release`.

## Before the first public release – checklist
- [ ] Audio source (`eathebook.org`) permission / licensing confirmed
- [ ] Reading texts and Synaxarium data: source and license confirmed
- [ ] Tested on a real Android 13+ device: notification permission, reminder, widgets, audio in background
- [ ] Screenshots captured, store listing complete
