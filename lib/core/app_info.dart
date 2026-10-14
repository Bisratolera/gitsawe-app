/// Static facts about the app.
///
/// [version] and [buildNumber] must match `version:` in pubspec.yaml
/// (`test/app_info_test.dart` fails if they drift apart).
class AppInfo {
  const AppInfo._();

  static const String name = 'Gitsawe';
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  static const String repoUrl = 'https://github.com/Bisratolera/gitsawe-app';
  static const String releasesUrl = '$repoUrl/releases';
  static const String privacyPolicyUrl = '$repoUrl/blob/main/PRIVACY_POLICY.md';
  static const String issuesUrl = '$repoUrl/issues';
}
