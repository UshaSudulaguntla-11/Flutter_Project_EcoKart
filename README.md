<div align="center">

# 🛒 EcoKart
### *A Modern, High-Performance Flutter Web Marketplace*

[![Flutter](https://img.shields.io/badge/Flutter-Cross--Platform-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Hosted on Render](https://img.shields.io/badge/Hosted%20on-Render-46E3B7?style=for-the-badge&logo=render&logoColor=black)](https://render.com)
[![Unsplash API](https://img.shields.io/badge/Powered%20by-Unsplash%20API-000000?style=for-the-badge&logo=unsplash&logoColor=white)](https://unsplash.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

*EcoKart is a modern, responsive e-commerce application built using Flutter. It delivers dynamic product discovery, seamless imagery via the Unsplash API, and secure build-time secret management.*

</div>

---

## 🚀 Features

### 🛒 1. Dynamic Marketplace & Catalog
* **Responsive Layout:** Optimized for seamless desktop, mobile (Android/iOS), and web viewports.
* **Product Discovery:** Category-based filtering and instant search capabilities.
* **Real-time Product Imagery:** Fetches high-resolution imagery directly via the **Unsplash REST API**.

### 🔒 2. Secure Secret Management
* **Zero Credential Leaks:** Implements `String.fromEnvironment` to pull API keys during build compilation.
* **CI/CD Integration:** Uses `--dart-define` inside Render's build pipeline to inject secrets safely without exposing them in public repositories.

### 🛍️ 3. Interactive Shopping Cart
* Real-time item additions and quantity updates.
* Instant subtotal calculations with responsive drawer components.
* Persistent local state management.

### ☁️ 4. Continuous Deployment
* Pre-configured pipeline for continuous deployment on **Render**.
* Automated Flutter Web compilation into static production release artifacts (`build/web`).

---

## 🛠️ Tech Stack

| Component | Technology |
| :--- | :--- |
| **Framework** | [Flutter](https://flutter.dev) |
| **Language** | [Dart](https://dart.dev) |
| **API Integration** | Unsplash REST API |
| **Hosting Platform** | Render Static Site |

---

## 📁 Project Structure

```text
Flutter_Project_EcoKart/
│
├── android/                 # Android native project configurations
├── ios/                     # iOS native project configurations
├── lib/                     # Main Dart codebase (UI, Services, Models)
├── web/                     # Web entry points, index.html & icons
├── .metadata                # Flutter project tracking metadata
├── analysis_options.yaml    # Linter & static code analysis rules
├── pubspec.yaml             # Flutter dependencies & asset configurations
└── README.md                # Project documentation
```

---

## ⚙️ How to Run Locally

### 1. Clone the Repository
```bash
git clone https://github.com/UshaSudulaguntla-11/Flutter_Project_EcoKart.git
cd Flutter_Project_EcoKart
```

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Application Locally
Provide your Unsplash API key using the `--dart-define` flag:

**For Web:**
```bash
flutter run -d chrome --dart-define=UNSPLASH_ACCESS_KEY=your_actual_access_key
```

**For Mobile (Android/iOS):**
```bash
flutter run --dart-define=UNSPLASH_ACCESS_KEY=your_actual_access_key
```

*(Note: If no key is provided, the app safely falls back to local placeholder assets).*

---

## ☁️ Render Deployment Configuration

This project is set up for automatic deployments on Render using the following build settings:

* **Environment:** `Static Site`
* **Build Command:** 
  ```bash
  git clone --depth 1 -b stable https://github.com/flutter/flutter.git && flutter/bin/flutter config --enable-web && flutter/bin/flutter build web --release --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY
  ```
* **Publish Directory:** `build/web`
* **Environment Variable:** `UNSPLASH_ACCESS_KEY` = `your_unsplash_access_key`

---

## 🎯 Key Learnings & Architecture

* **Secure Build-Time Configuration:** Managing environment variables across CI/CD environments and Flutter web.
* **Cross-Platform Responsive Design:** Creating fluid UIs with Flutter layouts for Web, Android, and iOS.
* **REST API Integration:** Asynchronous HTTP fetching and dynamic image rendering.

---

## 👩‍💻 Author

**Usha Sudulaguntla**
* GitHub: [@UshaSudulaguntla-11](https://github.com/UshaSudulaguntla-11)

---



<div align="center">
  <i>Built using Flutter & Dart.</i>
</div>
