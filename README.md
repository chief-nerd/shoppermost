# 🛒 Shoppermost

A beautiful cross-platform shopping list app powered by [Mattermost](https://mattermost.com/). Messages in a Mattermost channel become your shopping list — add items from any device, and check them off with a swipe.

## Features

- **Mattermost-backed** — your shopping list lives in a Mattermost channel, accessible from any Mattermost client too
- **Swipe to cart** — swipe items to toggle them in/out of your cart, then checkout to clear them
- **Offline cache** — items are cached locally with SQLite so the list loads instantly
- **Pull to refresh** — drag down to sync the latest items from the server
- **Light & dark themes** — toggle between system-automatic, light, or dark mode in settings
- **Cross-platform** — runs on iOS, Android, macOS, Linux, Windows, and Web

## Screenshots

<!-- Add screenshots here -->

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.5+)
- A self-hosted [Mattermost](https://mattermost.com/) instance with a dedicated channel for shopping

### Installation

```bash
git clone https://github.com/your-username/shoppermost.git
cd shoppermost
flutter pub get
```

### Running

```bash
# Run on your default device
flutter run

# Run on a specific platform
flutter run -d macos
flutter run -d chrome
flutter run -d ios
```

### Configuration

1. Launch the app and sign in with your Mattermost credentials (server URL, username, password).
2. Open **Settings** and select the channel you want to use as your shopping list.
3. Start adding items!

## How It Works

Shoppermost connects to the Mattermost REST API. Each message in the selected channel is displayed as a shopping list item. Reacting to a message with 👍 marks it as "in cart". Checking out removes the reactions so the flow resets.

| Action | Mattermost equivalent |
|---|---|
| Add item | Post a message to the channel |
| Put in cart | Add a 👍 reaction |
| Checkout | Remove all 👍 reactions from carted items |

## Architecture

The app follows a **Cubit-based** architecture using [flutter_bloc](https://pub.dev/packages/flutter_bloc):

```
lib/
├── main.dart                 # Entry point
├── app.dart                  # MaterialApp + providers
├── auth_wrapper.dart         # Routes auth state
├── theme/
│   └── app_theme.dart        # Centralized light/dark theme
├── cubit/
│   ├── api/                  # API client management
│   ├── auth/                 # Authentication state
│   ├── shopping/             # Shopping list state
│   └── theme/                # Theme mode persistence
├── models/
│   └── shopping_item.dart    # Item data model
├── screens/
│   ├── login_screen.dart     # Sign-in screen
│   ├── shopping_list_screen.dart  # Main list
│   └── settings_screen.dart  # Channel & theme settings
└── services/
    ├── database_service.dart # SQLite offline cache
    └── mattermost_api.dart   # Mattermost REST client
```

## Tech Stack

| Layer | Library |
|---|---|
| State management | [flutter_bloc](https://pub.dev/packages/flutter_bloc) |
| HTTP | [http](https://pub.dev/packages/http) |
| Persistence | [shared_preferences](https://pub.dev/packages/shared_preferences), [sqflite](https://pub.dev/packages/sqflite) |
| Testing | [bloc_test](https://pub.dev/packages/bloc_test), [mocktail](https://pub.dev/packages/mocktail) |

## Building for Sideloading

Shoppermost ships with a build pipeline for distributing outside the app stores. You can build locally with the included script or via GitHub Actions CI.

### Local builds

```bash
# Android APK
./build.sh android

# iOS — signed ad-hoc IPA (requires Apple Developer certificate + provisioning profile)
./build.sh ios

# iOS — unsigned (for re-signing later with AltStore, Sideloadly, etc.)
./build.sh ios --no-sign

# Both platforms at once
./build.sh all

# Pass extra Flutter flags
./build.sh android --build-name=1.2.0 --build-number=42
```

Outputs:
| Platform | Path |
|---|---|
| Android | `build/app/outputs/flutter-apk/app-release.apk` |
| iOS (signed) | `build/ios/ipa/*.ipa` |
| iOS (unsigned) | `build/ios/shoppermost-unsigned.ipa` |

### CI — GitHub Actions

Push a tag to trigger the pipeline automatically:

```bash
git tag v1.2.0
git push origin v1.2.0
```

Or trigger manually from the **Actions** tab using _workflow_dispatch_.

Download the APK / IPA from the workflow's **Artifacts** section.

#### Required secrets (for signed builds)

| Secret | Description |
|---|---|
| `ANDROID_KEYSTORE_BASE64` | Base64-encoded `.jks` keystore |
| `ANDROID_KEY_ALIAS` | Key alias inside the keystore |
| `ANDROID_KEY_PASSWORD` | Key password |
| `ANDROID_STORE_PASSWORD` | Keystore password |
| `IOS_CERTIFICATE_P12_BASE64` | Base64-encoded `.p12` Apple signing certificate |
| `IOS_CERTIFICATE_PASSWORD` | Password for the `.p12` |
| `IOS_PROVISIONING_PROFILE_BASE64` | Base64-encoded ad-hoc `.mobileprovision` |

> **Note:** Signing secrets are optional. Without them the Android APK is debug-signed and the iOS build produces an unsigned IPA.

### Installing on devices

**Android:** Transfer the `.apk` to the device and open it (enable _Install from unknown sources_ in settings).

**iOS (signed ad-hoc):** AirDrop the `.ipa` or use Apple Configurator. The device UDID must be in the provisioning profile.

**iOS (unsigned):** Use [AltStore](https://altstore.io/), [Sideloadly](https://sideloadly.io/), or a similar tool to install the `.ipa` with your Apple ID.

## Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
