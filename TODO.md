# TODO

## Architecture / Refactoring
- [x] Migrate `ShoppingListScreen` state management to a dedicated Cubit (`ShoppingCubit`), removing logic directly using `MattermostApi` inside UI components.
- [x] Implement proper error handling when the Mattermost API fails to fetch posts or post messages.
- [x] Dynamically resolve the `channelId` by searching for a channel named 'shopping'.

## Features
- [x] Display an error state/snackbar when API requests (e.g., login, sending message, checkout) fail.
- [x] Support caching of messages offline using `sqflite`.
- [ ] Support WebSocket connection to Mattermost to receive new list items in real-time without manual refresh.

## Mattermost API Client
- [ ] Add explicit error throwing / handling inside `mattermost_api.dart` methods.
- [ ] Parse pagination and implement endless scrolling for huge shopping lists.
