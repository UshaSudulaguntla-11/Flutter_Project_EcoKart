# 🛒 EcoKart

### A Modern Flutter Marketplace for Eco-Friendly, Plastic-Free Products

![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white)
![Hosted on Render](https://img.shields.io/badge/Hosted%20on-Render-46E3B7?logo=render&logoColor=white)
![Unsplash API](https://img.shields.io/badge/Unsplash-API-000000?logo=unsplash&logoColor=white)
![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)

EcoKart is a responsive shopping app built with **Flutter** and **Provider**. It lets customers discover **100 eco-friendly products**, add them to a cart, check out with full delivery details, and track every order. Product photos are fetched from the **Unsplash REST API**, and the API key is injected at **build time** so it is never stored in the code or the repository.

The project supports **UN Sustainable Development Goal 12: Responsible Consumption and Production**.

---

## 🌐 Live Demo

👉 **https://flutter-project-ecokart.onrender.com**

> The site runs on Render's free plan, so the first visit after a quiet period can take a little while to load.

---

## 📑 Table of Contents

1. [Features](#-features)
2. [App Pages](#-app-pages)
3. [SDG 12 Relevance](#-sdg-12-relevance)
4. [Tech Stack](#-tech-stack)
5. [Architecture](#-architecture)
6. [Project Structure](#-project-structure)
7. [Form Validation Rules](#-form-validation-rules)
8. [How to Run Locally](#-how-to-run-locally)
9. [Getting an Unsplash API Key](#-getting-an-unsplash-api-key)
10. [Render Deployment](#-render-deployment)
11. [Troubleshooting](#-troubleshooting)
12. [Limitations and Future Scope](#-limitations-and-future-scope)
13. [Key Learnings](#-key-learnings)
14. [Author](#-author)

---

## 🚀 Features

### 🛍️ 1. Product Catalog and Discovery
- **100 products** in 7 categories: Kitchen, Bath & Body, On the go, Home & Cleaning, Garden & Paper, Apparel & Accessories, Kids & Baby.
- **Search** by item name, brand, material or description.
- **Filters:** minimum rating (3.5, 4, 4.5 and up), a price range slider, and category chips.
- **Sorting:** popular, price low to high, price high to low, and rating.
- **Quick shortcuts** on the home page such as *Under ₹199*, *₹500 – ₹999* and *4.5★ & above*.
- Dedicated pages for **All Products, Deals of the Day (with live countdown), Bestsellers and New Arrivals**.

### 🖼️ 2. Product Imagery
- Real photos from the **Unsplash REST API**, found by searching a hand-picked keyword for each product.
- A **gallery of up to 5 pictures** per product with thumbnails, swipe, and a full-screen pinch-zoom viewer.
- Photographer credit shown as *"Photo by NAME on Unsplash"*.
- Found photos are **saved on the device**, so each product is searched only once.
- **Safe fallback:** if no key is given, the internet is off or the limit is reached, the app shows bundled pictures from `assets/products/`.

### 🔒 3. Secure Secret Management
- The Unsplash key is read with `String.fromEnvironment`, so it is supplied at build time with `--dart-define`.
- Nothing secret is committed to GitHub. On Render the key is stored as an environment variable.
- Only the **Access Key** is used. The Unsplash *Secret Key* is never needed or included.

### 👤 4. Accounts
- **Create account** and **sign in** with just email and password.
- Passwords are stored as a **SHA-256 hash**, never as plain text.
- The login is remembered after restarting the app.

### 🛒 5. Wishlist and Cart
- Heart any product to save it to the **wishlist**, and add everything to the cart in one tap.
- Cart with quantity buttons, swipe-to-remove, and a **free-delivery progress bar** (free above ₹499, otherwise ₹40).
- Price details: total MRP, discount, delivery fee and amount to pay.

### 📦 6. Checkout and Orders
- **Delivery form** (name, mobile, email, house, street, landmark, city, state, pincode) with validation. Details can be saved for next time.
- Payment choice: UPI, Cash on Delivery, or Card on Delivery.
- **One order per product.** Buying 2 products creates 2 separate orders, each with its own ID and tracking.
- **Order history** with a progress tracker, plus an **order detail page** showing the status timeline with timestamps, price breakdown, full address, payment method and expected delivery date.
- Orders, addresses and accounts are **saved on the device**.

### 🌍 7. SDG 12 Impact
- A short SDG 12 page explains the goal and how EcoKart supports it.
- It shows the user's **estimated plastic and CO₂ avoided** based on their orders.

### ☁️ 8. Continuous Deployment
- Pre-configured for **Render Static Site** deployment.
- Compiles Flutter Web into production files in `build/web`.

---

## 📱 App Pages

| Page | What it does |
|---|---|
| **Home** | Search, Shop Now banner, SDG strip, page shortcuts, preference chips, categories, deals, bestsellers, new arrivals |
| **Product List** | Search, category chips, rating and price filters, sorting (used for All Products, categories, deals and more) |
| **Product Detail** | Image gallery, price and discount, eco specifications, description, reviews, similar products |
| **Wishlist** | Saved products with *Add all to cart* |
| **Cart** | Items, quantities, free-delivery bar, price details |
| **Checkout** | Delivery form, payment method, order summary |
| **Orders** | One card per product order with a live progress tracker |
| **Order Detail** | Status timeline, price details, delivery address, payment information |
| **Account** | Sign in / create account, saved delivery details, orders, SDG page, sign out |
| **SDG 12** | The goal, how EcoKart helps, and the user's estimated impact |

---

## 🌍 SDG 12 Relevance

| UN target | How EcoKart supports it |
|---|---|
| **12.2** Sustainable use of natural resources | Products are reusable and made from natural or recycled materials |
| **12.5** Reduce waste | Reusable and compostable items replace single-use plastic |
| **12.8** Awareness for sustainable lifestyles | Every product shows its material and eco details, and the SDG page explains the goal |

The impact figures use rough averages of about **0.12 kg plastic** and **0.35 kg CO₂** avoided per item. They are estimates for illustration, not measured values.

---

## 🛠️ Tech Stack

| Component | Technology |
|---|---|
| Framework | Flutter |
| Language | Dart |
| State management | Provider (`ChangeNotifier`, `MultiProvider`, `Consumer`) |
| Local storage | `shared_preferences` |
| Password hashing | `crypto` (SHA-256) |
| API integration | Unsplash REST API via `http` |
| Fonts | `google_fonts` (Inter) |
| Hosting platform | Render Static Site |

---

## 🏗️ Architecture

EcoKart uses a layered architecture. Screens only display data and send user actions to providers. Providers hold the state and business rules. The data layer holds models, the product list, storage and the API.

```
+--------------------------------------------------------------+
|                          UI LAYER                            |
|  Home | Wishlist | Orders | Cart | Account  (bottom tabs)    |
|  ProductList | ProductDetail | Checkout | OrderDetail | SDG   |
+------------------------------+-------------------------------+
                               |  Consumer / Provider.of
+------------------------------v-------------------------------+
|                 STATE LAYER (ChangeNotifier)                 |
|  AuthProvider | CartProvider | WishlistProvider              |
|  OrdersProvider | AddressProvider | UnsplashProvider         |
+------------------------------+-------------------------------+
                               |
+------------------------------v-------------------------------+
|                          DATA LAYER                          |
|  Models | 100-product list | SharedPreferences | Unsplash API |
|  Bundled images (assets/products)                            |
+--------------------------------------------------------------+
```

| Provider | Responsibility |
|---|---|
| `AuthProvider` | Sign up, sign in, sign out, saved accounts, current user |
| `CartProvider` | Cart items, quantities, delivery fee, totals, savings |
| `WishlistProvider` | Saved products |
| `OrdersProvider` | Creates one order per cart product and keeps order history |
| `AddressProvider` | Saves each user's delivery details |
| `UnsplashProvider` | Searches Unsplash for product photos and remembers the results |

**Navigation:** a bottom navigation bar with five tabs (Shop, Wishlist, Orders, Cart, Account). Other screens open with the `Navigator`.

**Data saved on the device (`shared_preferences`):**

| Key | Contents |
|---|---|
| `ecokart_users` | Registered accounts (email, name, password hash) |
| `ecokart_current` | The signed-in user |
| `ecokart_addresses` | Saved delivery details |
| `ecokart_orders` | Order history |
| `ecokart_unsplash_v2` | Unsplash photo links already found |

---

## 📁 Project Structure

```
Flutter_Project_EcoKart/
│
├── android/                 # Android native project configurations
├── ios/                     # iOS native project configurations
├── web/                     # Web entry points, index.html & icons
├── lib/
│   └── main.dart            # App code: models, providers, screens
├── assets/
│   └── products/            # 500 bundled pictures (p1_1.jpg ... p100_5.jpg)
├── .metadata                # Flutter project tracking metadata
├── analysis_options.yaml    # Linter & static code analysis rules
├── pubspec.yaml             # Dependencies & asset configuration
└── README.md                # Project documentation
```

**Main sections inside `lib/main.dart`:** theme and helpers, models, the 100-product list, providers, app shell and navigation, home and product lists, product card and detail, wishlist, cart, address form and checkout, orders and order detail, SDG page, and the account screen.

---

## ✅ Form Validation Rules

| Field | Rule |
|---|---|
| Email | Must be a valid email address |
| Password | At least 6 characters |
| Full name | At least 2 characters |
| Mobile number | 10 digits, starting with 6, 7, 8 or 9 |
| House / Flat / Building | At least 3 characters |
| City | At least 2 characters |
| State | Must be chosen from the list |
| Pincode | 6 digits, not starting with 0 |

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

### 3. Run the Application
Provide your Unsplash Access Key with the `--dart-define` flag.

**For Web:**
```bash
flutter run -d chrome --dart-define=UNSPLASH_ACCESS_KEY=your_actual_access_key
```

**For Mobile (Android/iOS):**
```bash
flutter run --dart-define=UNSPLASH_ACCESS_KEY=your_actual_access_key
```

> **Note:** If no key is provided, the app safely falls back to the bundled pictures in `assets/products/`.

### 4. Build a Release (optional)
```bash
flutter build web --release --dart-define=UNSPLASH_ACCESS_KEY=your_actual_access_key
```
The output is created in `build/web`.

### 5. Try the App
1. Open the **Account** tab and choose **Create Account** with an email and password.
2. Browse products, tap **+ Add** on a few of them, and open the **Cart** tab.
3. Tap **Checkout**, fill in the delivery details, and press **Place Order**.
4. Open the **Orders** tab. Each product appears as its own order. Tap one to see its full history.

> Android release builds need `<uses-permission android:name="android.permission.INTERNET"/>` in `android/app/src/main/AndroidManifest.xml`.

---

## 🔑 Getting an Unsplash API Key

1. Create a free account at **https://unsplash.com/developers**.
2. Choose **Your apps → New Application** and accept the terms.
3. Copy the **Access Key** (use this one).
4. Do **not** use or share the **Secret Key**. If it is ever exposed, regenerate it on the Unsplash app page.

A new free app is in *demo mode* with about **50 requests per hour**. Because found photos are saved on the device, you can browse about 50 new products per hour and the rest load later. Unsplash can raise the limit if you apply for production access.

---

## ☁️ Render Deployment

This project is set up for automatic deployments on Render with these settings:

| Setting | Value |
|---|---|
| **Environment** | Static Site |
| **Publish Directory** | `build/web` |
| **Environment Variable** | `UNSPLASH_ACCESS_KEY` = your Unsplash Access Key |

**Build Command:**
```bash
git clone --depth 1 -b stable https://github.com/flutter/flutter.git && flutter/bin/flutter config --enable-web && flutter/bin/flutter build web --release --dart-define=UNSPLASH_ACCESS_KEY=$UNSPLASH_ACCESS_KEY
```

**How it works:**
1. Render pulls the latest code from GitHub on every push.
2. The build command downloads the Flutter SDK and compiles the web app.
3. The Access Key is passed in with `--dart-define`, so it is never committed.
4. Render serves the files in `build/web` as a static site.

---

## 🧰 Troubleshooting

| Problem | Fix |
|---|---|
| Product pictures look like drawings or green emoji tiles | The Unsplash key was not provided, or `assets/products/` is missing. Run with `--dart-define=UNSPLASH_ACCESS_KEY=...` and check the `assets:` line in `pubspec.yaml` |
| Build error about a missing assets directory | Make sure the `assets/products/` folder is committed to GitHub and listed in `pubspec.yaml` |
| Photos stop loading after browsing many products | The free Unsplash limit (about 50 per hour) was reached. Wait an hour; loaded photos stay saved |
| Photos do not load on Android release | Add the INTERNET permission to `AndroidManifest.xml` |
| Render build fails | Check that `UNSPLASH_ACCESS_KEY` is set in Render's environment variables |
| Old pictures still showing after a change | Run `flutter clean`, then `flutter pub get`, then run again |

---

## 🔭 Limitations and Future Scope

**Current limitations**
- No real payment gateway; the chosen payment method is recorded with the order.
- No backend server, so accounts and orders are stored only on the device and do not sync between devices.
- Order tracking advances automatically every minute to demonstrate the timeline.
- SDG impact numbers are estimates.

**Future scope**
- Firebase Authentication and Cloud Firestore for accounts and orders across devices.
- Online payments (Razorpay or UPI).
- Push notifications for order updates.
- Real customer reviews and a seller dashboard.

---

## 🎯 Key Learnings & Architecture

- **Secure build-time configuration:** managing secrets across CI/CD and Flutter web with `--dart-define`.
- **State management with Provider:** separating UI from business logic with `ChangeNotifier`.
- **Cross-platform responsive design:** fluid layouts that work on web, Android and iOS.
- **REST API integration:** asynchronous HTTP fetching, caching and graceful fallbacks.
- **Forms and validation:** regular-expression validation for email, mobile number and pincode.
- **Local persistence:** saving accounts, addresses and orders with `shared_preferences`.

---

## 🙏 Acknowledgements

- Photos from [Unsplash](https://unsplash.com) and its photographers.
- [United Nations Sustainable Development Goal 12](https://sdgs.un.org/goals/goal12).
- The Flutter and Provider communities.

---

## 👩‍💻 Author

**Usha Sudulaguntla**

GitHub: [@UshaSudulaguntla-11](https://github.com/UshaSudulaguntla-11)
