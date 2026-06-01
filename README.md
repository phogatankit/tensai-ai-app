# Tensai AI - Intelligent Conversational Assistant

Tensai AI is a modern cross-platform AI chat application built with Flutter and Firebase. It provides a smooth conversational experience similar to ChatGPT, featuring secure authentication, chat history management, and a clean, scalable architecture.

## ✨ Features

* 🤖 AI-powered conversations using OpenAI GPT models
* 🔐 Secure Firebase Authentication
* 💬 Real-time chat interface with smooth user experience
* 📚 Multiple chat sessions with persistent history
* ⚡ BLoC-based state management
* 🎨 Modern and responsive UI
* 📱 Cross-platform support (Android, iOS, Web, Windows, macOS, Linux)
* 🚨 Proper loading, error, and empty-state handling

---

## 🛠 Tech Stack

### Frontend

* Flutter
* Dart

### State Management

* BLoC / Flutter BLoC

### Backend & Services

* Firebase Authentication
* Cloud Firestore

### AI Integration

* OpenAI API (GPT Models)

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── network/
│   └── utils/
│
├── data/
│   └── models/
│
├── features/
│   ├── auth/
│   │   ├── bloc/
│   │   ├── screens/
│   │   └── widgets/
│   │
│   └── chat/
│       ├── bloc/
│       ├── screens/
│       └── widgets/
│
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

* Flutter SDK (Latest Stable Version)
* Firebase Project
* OpenAI API Key

### Clone Repository

```bash
git clone https://github.com/phogatankit/tensai-ai-app.git
cd tensai-ai-app
```

### Install Dependencies

```bash
flutter pub get
```

### Configure Firebase

1. Create a Firebase project.
2. Add Android/iOS/Web apps.
3. Download configuration files:

   * `google-services.json` → `android/app/`
   * `GoogleService-Info.plist` → `ios/Runner/`
4. Run:

```bash
flutterfire configure
```

### Run Application

```bash
flutter run
```

---

## 📦 Build APK

```bash
flutter build apk --release
```

APK Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

---

## 🎯 Key Learning Outcomes

* Clean Architecture Principles
* BLoC State Management
* Firebase Authentication
* API Integration
* Responsive UI Design
* Cross-Platform Development

---

## 👨‍💻 Author

Ankit kumar

GitHub:
https://github.com/phogatankit

LinkedIn:
www.linkedin.com/in/phogat-ankit



##
