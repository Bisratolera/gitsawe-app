#!/usr/bin/env bash
# Creates the upload keystore used to sign Gitsawe release builds and prints the
# values to store as GitHub secrets. Run it ONCE, on your own computer.
#
#   ./tools/create_keystore.sh
#
# Back the .jks file and the passwords up somewhere safe (password manager).
# Never commit them. If you lose the upload key you must ask Google Play to reset it.
set -euo pipefail

KEYSTORE="${1:-upload-keystore.jks}"
ALIAS="${2:-upload}"

if [[ -e "$KEYSTORE" ]]; then
  echo "Refusing to overwrite existing $KEYSTORE" >&2
  exit 1
fi

keytool -genkeypair -v \
  -keystore "$KEYSTORE" \
  -alias "$ALIAS" \
  -keyalg RSA -keysize 2048 -validity 10000

echo
echo "Keystore written to: $KEYSTORE"
echo
echo "Add these repository secrets (GitHub → Settings → Secrets and variables → Actions):"
echo "  ANDROID_KEYSTORE_BASE64   = $(base64 -w0 "$KEYSTORE" 2>/dev/null || base64 "$KEYSTORE" | tr -d '\n' | cut -c1-20)…  (full value: base64 -w0 $KEYSTORE)"
echo "  ANDROID_KEYSTORE_PASSWORD = the store password you just typed"
echo "  ANDROID_KEY_ALIAS         = $ALIAS"
echo "  ANDROID_KEY_PASSWORD      = the key password you just typed"
echo
echo "For local builds create android/key.properties:"
cat <<PROPS
storeFile=$(cd "$(dirname "$KEYSTORE")" && pwd)/$(basename "$KEYSTORE")
storePassword=<store password>
keyAlias=$ALIAS
keyPassword=<key password>
PROPS
