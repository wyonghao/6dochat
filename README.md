# DoChat MVP (Flutter)

DoChat is an **open-source, web-first MVP** Discourse Chat client built with Flutter.

> This project focuses on **Discourse Chat only** and is **not** a full forum client.

## MVP Scope

Implemented:
- Login with Discourse (OAuth Authorization Code + PKCE flow)
- Fetch available chat channels
- Open channel and load recent messages
- Send message to a channel
- Poll messages every ~7 seconds using REST
- Optional create/delete channel actions (if permissions allow)

Not implemented:
- WebSockets
- Push notifications
- Ads
- Payments
- Advanced forum features

---

## Architecture

Simple and readable structure with Provider state management:

```text
lib/
  auth/
  chat/
  models/
  services/
  screens/
  config.dart
  main.dart
```

Layers are separated:
- UI in `screens/`
- API and storage in `services/` + `auth/`
- Data models in `models/`

---

## Authentication Flow

This MVP uses OAuth Authorization Code + PKCE:

1. User taps **Login with Discourse**
2. App opens Discourse login page in browser/webview
3. Discourse redirects back to app callback URI
4. App exchanges auth code for access token
5. Token is stored securely using `flutter_secure_storage`
6. Token is sent as `Authorization: Bearer <token>` for chat API requests

> Your Discourse instance must be configured to allow this OAuth flow.

---

## Configuration

Edit `lib/config.dart` before running:

- `discourseBaseUrl`
- `oauthClientId`
- `oauthRedirectUri`

Defaults are placeholders and must be replaced.

---

## Run commands

```bash
flutter pub get
flutter run -d chrome
flutter run -d android
flutter run -d ios
```

---

## Discourse API notes

This project uses only REST endpoints for chat MVP operations:
- List channels
- List channel messages
- Send message
- Create/delete channel (best-effort, permission-dependent)

Because Discourse deployments differ, endpoint payload details may require small adjustments.

---

## Known limitations

- No realtime socket updates (polling only)
- No offline caching
- No rich message formatting
- No threading, reactions, or file upload
- Endpoint contracts may vary by Discourse version/plugins

---

## Future improvements

- Add WebSocket realtime chat updates
- Push notifications for mobile/web
- Better error telemetry and retry strategy
- Message pagination and local cache
- Rich chat UI (attachments, reactions, markdown)
- Optional monetization/ads/payments (out of MVP scope)
