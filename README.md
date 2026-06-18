# 🛒 ShopPrice - Flutter Shopping App

A complete, production-ready Flutter application for price comparison shopping with role-based admin panel and real-time Firebase backend.

## ✨ Features

### User Roles
- **👔 Admin**: Full control over items, categories, units, and workers
- **🛍️ Worker**: Browse items, search, view details

### Worker Features
- ✅ Email/password authentication
- ✅ Browse products by category
- ✅ Real-time search with filters
- ✅ View product details with ratings
- ✅ User profile management
- ✅ Auto-login session persistence

### Admin Features  
- ✅ Dashboard with real-time statistics
- ✅ Full CRUD for products (items)
- ✅ Full CRUD for categories
- ✅ Full CRUD for units
- ✅ Worker management (create, activate/deactivate, delete)
- ✅ Duplicate prevention for all entities
- ✅ Real-time updates across all connected clients

### Technical
- ✅ Firebase Authentication (email/password)
- ✅ Firestore real-time database
- ✅ Role-based access control (Firestore security rules)
- ✅ Material Design 3 dark theme
- ✅ Provider state management
- ✅ Form validation
- ✅ Error handling and user feedback
- ✅ Multi-platform (Android, iOS, Web, Windows)

---

## 🚀 Quick Start

### Prerequisites
- Flutter 3.10.8+ installed ([Get Flutter](https://flutter.dev/docs/get-started/install))
- Dart SDK (comes with Flutter)
- Firebase project ([Create one](https://console.firebase.google.com))

### Setup Instructions

#### Step 1: Clone/Download Project
```bash
cd d:\Ghost\shopprice
flutter pub get
```

#### Step 2: Create Firebase Project
See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for detailed steps:
1. Create Firebase project on console.firebase.google.com
2. Enable Authentication (Email/Password)
3. Create Firestore Database (production mode)
4. Download google-services.json for Android

#### Step 3: Configure Firebase
1. Update `lib/firebase_options.dart` with your Firebase config
2. Place `google-services.json` in `android/app/`
3. Publish Firestore security rules (see FIREBASE_SETUP.md)

#### Step 4: Run the App
```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point with Firebase init
├── firebase_options.dart        # Firebase configuration
├── core/
│   ├── theme/                   # Material Design 3 dark theme
│   ├── constants/               # App strings, sizes, colors
│   └── utils/                   # Helper utilities
├── models/                       # Data models with Firestore serialization
├── services/
│   └── firestore_service.dart   # Complete Firestore CRUD operations
├── providers/
│   ├── auth_provider_firebase.dart      # Firebase Authentication
│   ├── item_provider_firestore.dart     # Real-time items
│   ├── category_provider_firestore.dart # Real-time categories
│   ├── unit_provider_firestore.dart     # Real-time units
│   └── user_provider_firestore.dart     # User management
├── features/
│   ├── auth/                    # Login/registration screen
│   ├── worker_home/             # Worker: home, search, profile screens
│   ├── item_detail/             # Product detail view
│   └── admin/                   # Admin dashboard & management screens
└── widgets/                      # Reusable UI components

pubspec.yaml                     # Dependencies (Firebase, Provider, etc.)
FIREBASE_SETUP.md                # Firebase configuration guide
PART3_SETUP.md                   # Firebase integration checklist
PART3_IMPLEMENTATION_SUMMARY.md  # Implementation details
MIGRATION_GUIDE.md               # Upgrade guide from local to Firebase
```

---

## 🔑 Key Credentials for Testing

After Firebase setup, create these users:

**Admin User**
- Email: `admin@example.com`
- Password: `admin123`
- Role: `admin` (set in Firestore)

**Worker User**
- Email: `worker@example.com`
- Password: `worker123`
- Role: `worker` (set in Firestore)

Then add role field to each user in Firestore → users collection.

---

## 🎮 Testing the App

### Test Admin Features
1. Login with admin credentials
2. Click "Items" on dashboard
3. Add a new item (name, price, category, unit, etc.)
4. Item appears instantly in Firestore
5. Any connected clients see update in real-time

### Test Worker Features
1. Login with worker credentials
2. Browse items by category
3. Search for products
4. Click on product to see details
5. Profile shows your information

### Test Real-time Updates
1. Open app in two browser windows (Chrome)
2. Login as admin in first window
3. Add new item
4. Check second window - item appears instantly!

---

## 🔐 Security

### Authentication
- Firebase handles password hashing and security
- Automatic session persistence
- Re-authentication for sensitive operations

### Database Access
- **Admin Users**: Full CRUD on all collections
- **Worker Users**: Read-only on items, categories, units
- **Firestore Rules**: Enforce role-based access control

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md#step-7-firestore-security-rules) for security rules.

---

## 📊 Firestore Structure

```
shopprice-project/
├── users/              # User accounts and profiles
├── items/              # Products with details
├── categories/         # Product categories
├── units/              # Measurement units
└── activity_logs/      # Optional activity tracking
```

---

## 🛠️ Development

### Hot Reload
Press `r` in terminal while app is running:
```bash
flutter run
```

### Format Code
```bash
flutter format lib/
```

### Check for Errors
```bash
flutter analyze
```

### Get Dependencies
```bash
flutter pub get
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

---

## 📱 Supported Platforms

- ✅ Android (6.0+)
- ✅ iOS (11.0+)
- ✅ Web (Chrome, Firefox, Safari)
- ✅ Windows (10+)
- ✅ macOS (10.11+)
- ✅ Linux

---

## 🎨 Design System

**Theme**: Dark mode only
**Color Palette**:
- Primary: `#E65100` (Orange)
- Secondary: `#37474F` (Blue-gray)
- Tertiary: `#0480FF` (Bright Blue)
- Background: `#121212` (Dark)
- Surface: `#1E1E1E` (Darker)

**Typography**: Material Design 3 defaults
**Components**: Material 3 with custom styling

---

## 📚 Documentation

- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Complete Firebase setup guide
- **[PART3_SETUP.md](PART3_SETUP.md)** - Firebase integration checklist
- **[PART3_IMPLEMENTATION_SUMMARY.md](PART3_IMPLEMENTATION_SUMMARY.md)** - Technical details
- **[MIGRATION_GUIDE.md](MIGRATION_GUIDE.md)** - Upgrade from local to Firebase
- **[QUICK_START.md](QUICK_START.md)** - Quick reference guide

---

## 🐛 Troubleshooting

### "Permission denied" errors
1. Check Firestore security rules are published
2. Verify user role is set in Firestore
3. Wait 30 seconds for rules to propagate

### App won't start
1. Run `flutter clean`
2. Run `flutter pub get`
3. Check Firebase config in `firebase_options.dart`
4. Check `google-services.json` is in `android/app/`

### Can't login
1. Verify user exists in Firebase Authentication
2. Check user role is set in Firestore users collection
3. Check Firestore security rules

### Real-time updates not working
1. Ensure Firestore database is created
2. Check provider initialization in main.dart
3. Look for errors in browser console

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md#-troubleshooting) for more solutions.

---

## 📦 Dependencies

```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.5+1        # State management
  firebase_core: ^2.24.0    # Firebase initialization
  firebase_auth: ^4.15.0    # Authentication
  cloud_firestore: ^4.14.0  # Real-time database
```

---

## 🚀 Deployment

### Development
```bash
flutter run -d chrome        # Web
flutter run                   # Android/iOS
```

### Production
```bash
flutter build apk            # Android APK
flutter build web            # Web build
```

See [FIREBASE_SETUP.md](FIREBASE_SETUP.md#-next-production) for production setup.

---

## 📈 Performance

- Real-time Firestore streams for instant updates
- Consumer pattern for efficient rebuilds
- Lazy loading of images
- Optimized queries with proper indexing

---

## 🤝 Contributing

This is a complete project example. Feel free to:
- Extend with more features
- Customize colors and styling
- Add more admin screens
- Integrate additional Firebase services

---

## 📝 License

This project is provided as-is for educational and commercial use.

---

## 📞 Support Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)

---

## 🎉 What's Next

1. **Add shopping cart** - Save items to cart collection
2. **Add payment integration** - Stripe or similar
3. **Add reviews** - User ratings and comments
4. **Add notifications** - Firebase Cloud Messaging
5. **Add analytics** - Firebase Analytics
6. **Add user reports** - Custom reports for admin

---

**ShopPrice** - Building the future of price comparison. 🚀

---

*Last Updated: May 6, 2026*

