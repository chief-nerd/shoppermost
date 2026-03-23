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

## Contributing

Contributions are welcome! Please open an issue first to discuss what you'd like to change.

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
