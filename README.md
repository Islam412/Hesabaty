# debt_cash_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


---

## 🔗 Shareable Receipts & Public Statements | الإيصالات القابلة للمشاركة والروابط العامة

Every receipt exported from the app is a **two-part artifact**:

| Part | What it contains |
|---|---|
| 🖼️ **Shareable Image (PNG)** | Receipt card with **sender & recipient details, amount, logo, date, note**, plus an embedded **QR code** pointing to a public URL. |
| 🌐 **Public Web Page** (read-only) | URL like `hesabaty.app/r/<token>` — no login required. Shows **general balance, total received/paid, full transaction history** with running balances. |

### How it works
1. Each transaction generates a unique non-guessable **token** (UUID v4).
2. The `ReceiptCard` renders the design and QR badge from that token.
3. Opening the QR on a device with the app launches the in-app statement viewer; otherwise it opens the web page.
4. The backend serves a public read-only projection — no sensitive data is exposed.

### Arabic
كل إيصال يُصدَّر من التطبيق هو أداة من جزئين:
- **صورة PNG** فيها بيانات المرسل والمرسل إليه + المبلغ + QR Code.
- **صفحة ويب عامة** `hesabaty.app/r/<token>` بدون تسجيل دخول، تعرض الرصيد وسجل كل العمليات.

> ⚙️ **Backend plan:** Lightweight Cloudflare Workers / Firebase Functions reading from a public-only projection of each contact's transactions.
