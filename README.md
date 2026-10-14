# ግጻዌ · Gitsawe

Daily readings, Synaxarium, Mahlet and teachings of the Ethiopian Orthodox Tewahedo Church — offline-first, no account, no ads, no tracking.

[![CI](https://github.com/Bisratolera/gitsawe-app/actions/workflows/ci.yml/badge.svg)](https://github.com/Bisratolera/gitsawe-app/actions/workflows/ci.yml)

## Features

- **Today's Gitsawe** with previous/next-day navigation (Ethiopian calendar, Ge'ez / Amharic / English text)
- **Synaxarium (ስንክሳር)** for every day of the year – even on days without a dedicated Gitsawe entry
- Daily, monthly and seasonal Gitsawe, feasts, Mahlet service, teachings
- **Full-text search** across titles, Synaxarium and verses
- **Daily reminder** at a time you choose, each carrying that day's reading
- **Home-screen widgets** (7 sizes) that move on to the next day by themselves
- Audio library with background playback and a mini player
- Bookmarks, sharing as text or image, dark mode, text size, Amharic / English interface

## Download

Signed APKs and the Play bundle are attached to every [GitHub release](https://github.com/Bisratolera/gitsawe-app/releases).
Pick `…-arm64-v8a.apk` for almost every phone made after 2017, or `…-universal.apk` if unsure.
Each release lists `SHA256SUMS.txt` so you can verify the download.

## Build from source

Requires Flutter (stable channel, Dart ≥ 3.12) and JDK 17.

```bash
flutter pub get
flutter test
flutter run                      # debug on a device/emulator
flutter build apk --release      # signed with the debug key unless android/key.properties exists
```

## Releasing (Google Play + GitHub)

See [docs/RELEASING.md](docs/RELEASING.md). In short: create the upload key once
(`tools/create_keystore.sh`), add four secrets, then `git tag v1.0.0 && git push --tags`.

Store listing text, data-safety answers and graphics live in [docs/play-store/](docs/play-store/).

## Project layout

```
lib/
  core/        theme, Ethiopian calendar maths, UI strings (am/en), app info
  models/      JSON data models
  services/    data loading, notifications, widgets, audio, settings
  screen/      app screens
  widgets/     shared UI
assets/data/   bundled readings (daily, monthly, seasonal, feasts, Mahlet, Synaxarium)
android/       Android project, home-screen widgets in MainActivity.kt
```

## Notes

- The audio lessons are **streamed from eathebook.org**. Make sure you have the right to
  link to that content before publishing a store release.
- The Ethiopian date conversion is implemented twice (Dart and Kotlin, for widgets). Keep both in sync.

## Privacy

See [PRIVACY_POLICY.md](PRIVACY_POLICY.md). The app collects no personal data.
