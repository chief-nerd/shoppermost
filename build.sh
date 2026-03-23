#!/usr/bin/env bash
#
# build.sh — Build Shoppermost for sideloading (Android APK / iOS IPA)
#
# Usage:
#   ./build.sh android          Build release APK
#   ./build.sh ios              Build release IPA (ad-hoc, requires signing)
#   ./build.sh ios --no-sign    Build unsigned .app, package as IPA
#   ./build.sh all              Build both
#
set -euo pipefail

APP_NAME="shoppermost"
BUILD_DIR="build"

# ── Helpers ──────────────────────────────────────────────────────
info()  { printf '\033[1;34m→ %s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m✔ %s\033[0m\n' "$*"; }
die()   { printf '\033[1;31m✖ %s\033[0m\n' "$*" >&2; exit 1; }

ensure_flutter() {
  command -v flutter >/dev/null 2>&1 || die "flutter not found in PATH"
}

# ── Android ──────────────────────────────────────────────────────
build_android() {
  info "Building Android APK (release)…"
  flutter build apk --release "$@"
  local apk="$BUILD_DIR/app/outputs/flutter-apk/app-release.apk"
  [[ -f "$apk" ]] || die "APK not found at $apk"
  ok "APK ready: $apk"
}

# ── iOS ──────────────────────────────────────────────────────────
build_ios() {
  local no_sign=false
  local extra_args=()

  for arg in "$@"; do
    case "$arg" in
      --no-sign) no_sign=true ;;
      *) extra_args+=("$arg") ;;
    esac
  done

  if $no_sign; then
    info "Building iOS (unsigned)…"
    flutter build ios --release --no-codesign "${extra_args[@]}"

    info "Packaging unsigned IPA…"
    local payload_dir="$BUILD_DIR/ios/ipa/Payload"
    mkdir -p "$payload_dir"
    cp -r "$BUILD_DIR/ios/iphoneos/Runner.app" "$payload_dir/"
    (cd "$BUILD_DIR/ios/ipa" && zip -qr "../$APP_NAME-unsigned.ipa" Payload)
    ok "Unsigned IPA ready: $BUILD_DIR/ios/$APP_NAME-unsigned.ipa"
  else
    info "Building signed iOS IPA (ad-hoc)…"
    flutter build ipa --release \
      --export-options-plist=ios/ExportOptions.plist \
      "${extra_args[@]}"
    ok "Signed IPA ready in: $BUILD_DIR/ios/ipa/"
  fi
}

# ── Main ─────────────────────────────────────────────────────────
ensure_flutter

target="${1:-}"
shift 2>/dev/null || true

case "$target" in
  android)
    build_android "$@"
    ;;
  ios)
    build_ios "$@"
    ;;
  all)
    build_android "$@"
    build_ios "$@"
    ;;
  *)
    echo "Usage: $0 {android|ios|all} [flutter build flags]"
    echo ""
    echo "Examples:"
    echo "  $0 android                          # Release APK"
    echo "  $0 ios                              # Signed ad-hoc IPA"
    echo "  $0 ios --no-sign                    # Unsigned IPA"
    echo "  $0 all --build-name=1.2.0           # Both with version"
    exit 1
    ;;
esac
