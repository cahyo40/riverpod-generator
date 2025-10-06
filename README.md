# Flutter Code Generator

Sebuah alat code generator untuk Flutter yang membantu menghasilkan boilerplate code dengan struktur clean architecture dan state management menggunakan Riverpod.

## 📋 Daftar Isi
- [Fitur](#-fitur)
- [Persiapan Awal](#-persiapan-awal)
- [Instalasi](#-instalasi)
- [Cara Menggunakan](#-cara-menggunakan)
- [Struktur Project](#-struktur-project)
- [Contoh Lengkap](#-contoh-lengkap)
- [Troubleshooting](#-troubleshooting)

## 🎯 Fitur

### Perintah yang Tersedia
- **`page:<name>`** - Membuat halaman lengkap dengan struktur feature-based
- **`provider:<name>`** - Membuat provider dengan Riverpod AsyncNotifier
- **`model:<name>`** - Membuat data model dengan Freezed
- **`widget:<name>`** - Membuat custom widget
- **`screen <screen_name> on <page_name>`** - Membuat screen di dalam page yang sudah ada
- **`repository:<repo_name> on <page_name>`** - Membuat repository di dalam page yang sudah ada

## 🚀 Persiapan Awal

### 1. Buat Project Flutter Baru
```bash
flutter create my_flutter_app
cd my_flutter_app
```

### 2. Tambahkan Dependencies yang Diperlukan

Edit file `pubspec.yaml` dan tambahkan dependencies berikut:

```yaml
name: my_flutter_app
description: "A Flutter project with code generator"

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  # Tambahkan dependencies berikut:
  flutter_riverpod: ^2.4.9
  freezed_annotation: ^2.4.1
  go_router: ^13.0.0
  riverpod_annotation: ^2.3.3

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  # Tambahkan dev dependencies berikut:
  build_runner: ^2.4.7
  freezed: ^2.4.5
  riverpod_generator: ^2.3.7

flutter:
  uses-material-design: true
```

### 3. Install Dependencies
```bash
flutter pub get
```

## 📥 Instalasi

### 1. Download File Generator

Letakkan kedua file ini di **root project** Flutter Anda:

- **`generate.dart`** - File generator utama
- **`tasks.json`** - Konfigurasi VS Code tasks (opsional)

Struktur project Anda akan terlihat seperti:
```
my_flutter_app/
├── generate.dart          # ✅ File generator
├── tasks.json            # ✅ File tasks VS Code
├── pubspec.yaml
├── lib/
│   └── main.dart
└── ... (file lainnya)
```

### 2. Verifikasi Instalasi

Jalankan perintah berikut untuk memastikan generator berfungsi:
```bash
dart generate.dart
```

Jika berhasil, Anda akan melihat output:
```
Usage: dart generate.dart <command>:<name>
Available commands: page, provider, model, widget, repository
```

## 💻 Cara Menggunakan

### 🎯 Cara 1: Menggunakan Command Line (Semua Editor)

#### Generate Halaman Lengkap
```bash
# Generate halaman home
dart generate.dart page:home

# Generate halaman profile dengan nested name
dart generate.dart page:user.profile

# Generate halaman settings
dart generate.dart page:settings
```

#### Generate Komponen Individual
```bash
# Generate provider
dart generate.dart provider:user

# Generate model
dart generate.dart model:product

# Generate widget
dart generate.dart widget:custom_button
```

#### Generate di Dalam Page yang Sudah Ada
```bash
# Generate screen login di dalam home page
dart generate.dart screen login on home

# Generate repository auth di dalam home page
dart generate.dart repository:auth on home
```

### 🖥️ Cara 2: Menggunakan VS Code Tasks (Recommended)

#### Setup Tasks di VS Code

1. **Buka folder project** di VS Code
2. **Copy file `tasks.json`** ke folder `.vscode/` di root project:
   ```
   my_flutter_app/
   ├── .vscode/
   │   └── tasks.json          # ✅ File tasks
   ├── generate.dart
   ├── lib/
   └── ...
   ```

3. **Restart VS Code** jika diperlukan

#### Menggunakan Tasks

1. **Buka Command Palette**:
   - `Ctrl+Shift+P` (Windows/Linux)
   - `Cmd+Shift+P` (Mac)

2. **Pilih "Tasks: Run Task"**

3. **Pilih generator yang diinginkan**:
   - `Generate Page` - Membuat halaman baru
   - `Generate Provider` - Membuat provider baru  
   - `Generate Screen on Page` - Membuat screen di page tertentu
   - `Generate Repository on Page` - Membuat repository di page tertentu
   - `Generate Model` - Membuat data model
   - `Generate Widget` - Membuat custom widget

4. **Masukkan nama** ketika diminta

## 📁 Struktur Project yang Dihasilkan

### Setelah Menjalankan `page:home`
```
lib/
├── features/
│   └── home/
│       ├── presentation/
│       │   ├── pages/
│       │   │   └── home_page.dart
│       │   └── providers/
│       │       └── home_provider.dart
│       ├── domain/
│       │   ├── models/
│       │   │   └── home_model.dart
│       │   └── repositories/
│       │       └── home_repository.dart
│       └── data/
│           ├── repositories/
│           │   └── home_repository_impl.dart
│           └── datasources/
│               └── home_datasource.dart
├── core/
│   └── navigation/
│       ├── app_router.dart
│       └── route_paths.dart
└── main.dart
```

### Setelah Menjalankan `screen login on home`
```
lib/features/home/presentation/pages/screens/
└── login_screen.dart
```

## 🏗️ Contoh Lengkap Membuat Fitur

### Langkah 1: Buat Halaman Home
```bash
dart generate.dart page:home
```

**Output:**
```
✅ Generated page: lib/features/home/presentation/pages/home_page.dart
✅ Generated provider: lib/features/home/presentation/providers/home_provider.dart
✅ Generated model: lib/features/home/domain/models/home_model.dart
✅ Generated repository: lib/features/home/domain/repositories/home_repository.dart
✅ Updated app router
```

### Langkah 2: Buat Screen Login di Home
```bash
dart generate.dart screen login on home
```

**Output:**
```
✅ Generated screen: lib/features/home/presentation/pages/screens/login_screen.dart
📁 Location: lib/features/home/presentation/pages/screens/
🎉 Screen "Login" successfully created on page "home"
```

### Langkah 3: Buat Repository Auth di Home
```bash
dart generate.dart repository:auth on home
```

**Output:**
```
✅ Generated abstract repository: lib/features/home/domain/repositories/auth_repository.dart
✅ Generated implementation repository: lib/features/home/data/repositories/auth_repository_impl.dart
📁 Location: lib/features/home/
🎉 Repository "Auth" successfully created on page "home"
```

### Langkah 4: Update main.dart

Edit `lib/main.dart` untuk menggunakan generated code:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/navigation/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);
    
    return MaterialApp.router(
      routerConfig: router,
      title: 'My Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
```

### Langkah 5: Generate Freezed Files

Jalankan build_runner untuk generate file Freezed dan Riverpod:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### Langkah 6: Jalankan Aplikasi

```bash
flutter run
```

## 🔧 Konfigurasi Routing Otomatis

Generator secara otomatis akan:

1. **Membuat file routing** di `lib/core/navigation/`
2. **Menambahkan route** baru ke `app_router.dart`
3. **Menambahkan import** yang diperlukan
4. **Update route paths** di `route_paths.dart`

## ❗ Troubleshooting

### Error: "Target of URI doesn't exist"
```bash
# Jalankan build_runner setelah generate code
flutter pub run build_runner build --delete-conflicting-outputs
```

### Error: "Page does not exist"
- Pastikan page sudah dibuat sebelum menambahkan screen/repository
- Cek daftar page yang tersedia dengan menjalankan generator tanpa arguments

### Error: Dependencies not found
```bash
# Pastikan dependencies terinstall
flutter pub get

# Atau upgrade dependencies
flutter pub upgrade
```

### File tasks.json tidak terbaca di VS Code
- Pastikan file berada di folder `.vscode/`
- Restart VS Code
- Buka Command Palette dan ketik "Reload Window"

## 🎉 Selamat!

Anda berhasil mengatur Flutter Code Generator! Sekarang Anda bisa:

- ✅ Generate halaman lengkap dengan struktur clean architecture
- ✅ Generate provider dengan Riverpod state management  
- ✅ Generate model dengan Freezed
- ✅ Generate screen dan repository di dalam page yang sudah ada
- ✅ Auto-configure routing dengan Go Router
- ✅ Gunakan melalui command line atau VS Code tasks

**Happy Coding!** 🚀