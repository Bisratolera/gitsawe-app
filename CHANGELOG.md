# Changelog

## 1.0.0

First public release.

### Fixed
- Daily reminders repeated the same reading title forever; each day now has its own notification (14-day rolling window).
- Re-enabling notifications in Settings scheduled nothing, and disabled notifications were re-scheduled at every launch.
- Days without a Gitsawe entry (~20% of the year) showed an empty screen; the Synaxarium is now shown.
- "Clear cache" emptied every list until the app was restarted.
- Home-screen widgets showed yesterday's reading until the app was opened; they now compute today's date natively.
- The widget refresh button did nothing.
- Today screen stayed on the previous date if the app was left open overnight.
- Missed-readings feature was never wired up and used incorrect logic.
- Mini player showed a stale title when playback advanced or was controlled from the notification.
- Dark mode rendered white cards with white text.
- Onboarding "Skip" button and page dots were invisible.
- Search results opened a screen whose menu button did nothing; bookmarks could not be opened.
- "Seasonal" and "Feasts" shortcuts opened the monthly list; feasts counter always showed 0.
- Typo in month name (ጥርር → ጥር); duplicate 02-08 entry removed.
- Language setting did nothing.
- Placeholder counter widget test replaced with real tests.

### Added
- Reminder time picker, previous/next-day navigation, full-text search.
- Seasonal Gitsawe and Feasts screens, bookmarks open the reading.
- Amharic / English interface, in-app privacy policy, real version info.
- Audio progress bar, playback error message.

### Release engineering
- Real application id (`com.gitsawe.app`), release signing via `key.properties`, target SDK 36, R8 rules.
- Removed exact-alarm permissions (not allowed for this kind of app on Google Play).
- GitHub Actions for CI and for signed GitHub releases / Play uploads.
