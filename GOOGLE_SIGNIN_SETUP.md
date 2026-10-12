# Google sign-in (Firebase project `collectionbolw`)

## 1. Backend .env (live server)
```
FIREBASE_PROJECT_ID=collectionbolw
FIREBASE_API_KEY=AIzaSyBPI41L-uJKVmaZbbTOo_uL63WlpLmNWn8
FIREBASE_AUTH_DOMAIN=collectionbolw.firebaseapp.com
FIREBASE_STORAGE_BUCKET=collectionbolw.firebasestorage.app
FIREBASE_MESSAGING_SENDER_ID=972805339299
FIREBASE_APP_ID=1:972805339299:web:595ad6369f18777dc36716
FIREBASE_MEASUREMENT_ID=G-LMH501FL42
```
Only `FIREBASE_PROJECT_ID` is needed to verify tokens (the `aud` claim must equal it;
`iss` must be `https://securetoken.google.com/collectionbolw`). Verify the signature
against Google's public keys (https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com).
No service-account key is required for verification.

## 2. API endpoint the app calls (backend must add it)
`POST /api/auth/google`  body: `{ "id_token": "<firebase id token>", "as": "customer" | "agent" }`
1. Verify the token, read `email`, `name`, `uid` (= google/firebase uid), `email_verified`.
2. Find the account by `firebase_uid`, else by `email`; if found by email, link the uid.
3. `as=customer`: create the customer if new (store name, email, firebase_uid, provider=google, no password).
4. `as=agent`: no agent for this email -> `403 {"code":"not_an_agent","message":"..."}`; inactive -> 403.
5. Success: `200` with the SAME body as `POST /api/login` (token, expires_in, user/partner fields, roles).
Add nullable `firebase_uid` (unique) and `auth_provider` columns to the customers and partners tables.

## 3. Firebase console
- Authentication > Sign-in method > enable **Google**.
- Add an Android app `com.wgghana.flexiphones` (add SHA-1 and SHA-256 of the release AND Play-signing keys)
  and download `google-services.json` into `android/app/`.
- Add an iOS app `com.wgghana.flexiphones`, download `GoogleService-Info.plist` into `ios/Runner/`
  (add it to the Runner target in Xcode), then add a URL type in `ios/Runner/Info.plist`
  whose scheme is the `REVERSED_CLIENT_ID` value from that plist.
- The web config you pasted is for a web app; the mobile apps need their own files above.

## 4. App Store note
Apps that offer Google login on iOS generally must also offer Sign in with Apple (guideline 4.8).

## 5. Account linking (same person, email+password AND Google)
In `POST /api/auth/google`, match the user by **verified email** (case-insensitive) BEFORE creating anything:
- Found by `firebase_uid` -> sign in.
- Else found by `email` (existing email/password account) and `email_verified` is true -> **link**: set
  `firebase_uid`, keep the same user id/orders/wallet, and sign them into that SAME account. Never create a duplicate.
- Else create a new account (no password; they can use "Forgot password" later to add one).
Reject the token if `email_verified` is false (prevents account takeover).

## 6. "I am not a robot" (Cloudflare Turnstile)
Add to the API .env (server only, never in the app):
```
TURNSTILE_SITE_KEY=0x4AAAAAAAFUwGEaW3t9araJB
TURNSTILE_SECRET_KEY=<your Turnstile secret key>
```
The app sends `cf_turnstile_token` with `/login`, `/customer/email-verification` and `/auth/google`.
Verify each one: POST https://challenges.cloudflare.com/turnstile/v0/siteverify with `secret`, `response` (the token)
and optional `remoteip`; reject the request unless the answer has `"success": true`.
In Cloudflare, the widget's Hostname list must contain `flexiphones.app` (the app loads the check under that host).
