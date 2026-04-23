# Agro Connect

Agro Connect is a Flutter farmer marketplace app with Buyer and Seller roles.

## Features
- Firebase email/password authentication with role-based onboarding.
- Seller dashboard: create crop listing with image upload, mandi rate fetch, delete listing, manage requests.
- Buyer dashboard: browse listings, search by crop, filter by location, send buy request.
- Order management with statuses: `pending`, `accepted`, `rejected`, `delivered`.
- Built-in chat between buyer and seller using Firestore chat rooms.
- Riverpod-based state management and scalable service/provider architecture.

## Folder Structure
- `lib/models/` - data models
- `lib/services/` - Firebase and API services
- `lib/providers/` - Riverpod providers and controllers
- `lib/screens/` - auth, buyer, seller, shared screens
- `lib/widgets/` - reusable UI widgets

## Setup
1. Install Flutter SDK.
2. Add Firebase to the app:
   - Create Firebase project
   - Enable Authentication (Email/Password)
   - Enable Firestore and Storage
3. Run:
   - `flutterfire configure`
   - This generates platform-specific Firebase options.
4. Replace `lib/firebase_options.dart` with generated file.
5. Install dependencies:
   - `flutter pub get`
6. Run app:
   - `flutter run`

## Firestore Collections
- `users/{uid}`
- `crops/{cropId}`
- `orders/{orderId}`
- `chats/{roomId}/messages/{messageId}`

## Notes
- Mandi rates are fetched from the public Indian agriculture dataset API.
- For production, move API key to secure backend/config and add strict Firestore/Storage security rules.
