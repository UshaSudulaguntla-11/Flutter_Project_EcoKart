# EcoKart – Eco-Friendly Marketplace (Flutter)

A shopping app with 100 plastic-free, eco-friendly products that supports
**UN SDG 12: Responsible Consumption and Production**.

## Features
- Sign up / sign in with email and password (saved on the device, passwords hashed)
- 100 products in 7 categories, each with a 5-picture gallery and full details
- Search by item name, filter by rating and price, sort, category pages
- Pages: All Products, Deals of the Day, Bestsellers, New Arrivals
- Wishlist and cart with free-delivery progress (free above Rs 499, else Rs 40)
- Checkout form: name, mobile, email, address, city, state, pincode (validated)
- One order per product, with order history, status timeline and full details
- SDG 12 page with estimated plastic and CO2 saved from your orders
- Orders, addresses and accounts are saved on the device

## Tech
Flutter, Provider (state management), shared_preferences, crypto, http, google_fonts.

## Run it
1. Create a Flutter project and copy these files in:
   ```
   flutter create ecokart
   ```
   Copy `lib/main.dart`, `pubspec.yaml` and the whole `assets/` folder over the
   ones in the new project. Delete the default `test/widget_test.dart`.
2. Install and run:
   ```
   flutter clean
   flutter pub get
   flutter run
   ```
3. Android release builds need this line in
   `android/app/src/main/AndroidManifest.xml` (above `<application>`):
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```

## Real product photos from Unsplash (optional)
1. Create a free app at https://unsplash.com/developers and copy the **Access Key**.
2. Open `lib/secrets.dart` and paste it between the quotes:
   ```dart
   const String kUnsplashAccessKey = 'YOUR_ACCESS_KEY';
   ```
3. Add this line to `.gitignore` so the key is never uploaded to GitHub:
   ```
   lib/secrets.dart
   ```
   (`lib/secrets.example.dart` is the empty template that stays on GitHub.)
   Never use the Secret Key in the app.
4. The app searches Unsplash for each product, saves the result on the device,
   and shows "Photo by NAME on Unsplash". Free keys allow about 50 searches an
   hour. Without a key the bundled pictures in `assets/products/` are used.

To use your own photos, put files named like `p1_1.jpg` (product 1, picture 1)
in `assets/products/`.

## Project structure
```
lib/main.dart        all app code (models, providers, screens)
lib/secrets.dart     your private Unsplash key (ignored by git)
assets/products/     500 bundled product pictures (p1_1.jpg ... p100_5.jpg)
pubspec.yaml         packages and assets
```
