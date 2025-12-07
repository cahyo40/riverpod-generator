
# 🚀 Flutter Code Generator  
**Otomatisasi boilerplate Flutter + Clean Architecture + Riverpod**

---

## 📌 Fitur Unggulan
| Fitur | Keterangan |
|-------|------------|
| ✅ `init` | **Otomatis setup project** - dependency, folder, main.dart, tasks.json |
| ✅ `page:<name>` | Generate halaman lengkap (presentation, domain, data) |
| ✅ `provider:<name>` | AsyncNotifier + Riverpod |
| ✅ `model:<name>` | Freezed + JSON Serializable |
| ✅ `screen <name> on <page>` | Sub-screen di page yang sudah ada |
| ✅ `repository:<name> on <page>` | Abstract + Implementation + Datasource |
| ✅ `entity:<name> on <page>` | Generate entity class pada domain layer |
| ✅ `crud:<name>` | Template CRUD lengkap |
| ✅ `--help` | Menampilkan bantuan perintah |
| ✅ VS Code Tasks | Tanpa install ekstensi tambahan |



## 🎯 Cara Mulai (Baru)

### 1. Buat Project Flutter
```bash
flutter create my_app
cd my_app
```

### 2. Letakkan `generate.dart` di Root
```bash
git clone https://github.com/cahyo40/riverpod-generator.git
# atau copy manual
```

### 3. Jalankan Init (Otomatis Semua)
```bash
dart generate.dart init
```

> ⚠️ Perintah ini akan:
> - Menambahkan dependency ke `pubspec.yaml`
> - Menjalankan `flutter pub get`
> - Buat folder struktur Clean Architecture
> - Buat/update `main.dart` dan `.vscode/tasks.json`

---

## 📂 Struktur Hasil `init`
```
my_app/
├── generate.dart
├── pubspec.yaml (sudah terupdate)
├── .vscode/
│   └── tasks.json (siap pakai)
├── lib/
│   ├── main.dart (sudah pakai ProviderScope + GoRouter)
│   ├── features/
│   ├── core/navigation/
│   ├── widgets/
│   ├── providers/
│   └── models/
```

---

## 🚀 Generate Fitur Baru

### Halaman Lengkap
```bash
dart generate.dart page:home
dart generate.dart page:user.profile
```

### Komponen Individual
```bash
dart generate.dart provider:auth
dart generate.dart model:product
dart generate.dart widget:custom_button
```

### Sub-Screen, Entity & Repository
```bash
dart generate.dart screen settings on home
dart generate.dart repository:cart on home
dart generate.dart entity:product on home
```

### Bantuan
```bash
dart generate.dart --help
```

### Template CRUD
```bash
dart generate.dart crud:product
```

---

## 🖥️ Gunakan di VS Code (Opsional)

1. Tekan `Ctrl+Shift+P`
2. Pilih **Tasks: Run Task**
3. Pilih:
   - `Generate Page`
   - `Generate Provider`
   - `Generate Screen on Page`
   - `Generate CRUD Template`
   - dll.

---

## 🔧 Build Generated Code

Setelah generate, jalankan:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## ✅ Contoh Lengkap 30 Detik

```bash
# 1. Init project
dart generate.dart init

# 2. Generate halaman home
dart generate.dart page:home

# 3. Generate screen & repository
dart generate.dart screen profile on home
dart generate.dart repository:user on home

# 4. Build generated files
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Run
flutter run
```

---

## 📋 Troubleshooting Cepat

| Masalah | Solusi |
|---------|--------|
| **URI tidak ditemukan** | `flutter pub run build_runner build --delete-conflicting-outputs` |
| **Page tidak ditemukan** | Pastikan sudah `dart generate.dart page:nama` dulu |
| **Tasks VS Code tidak muncul** | Pastikan `.vscode/tasks.json` ada, lalu restart VS Code |

---

## 📦 Dependency Otomatis (Ditambahkan `init`)

| Tujuan | Package |
|--------|---------|
| State Management | `flutter_riverpod`, `hooks_riverpod`, `riverpod_annotation`, `flutter_hooks` |
| Routing | `go_router` |
| Model | `freezed_annotation`, `json_annotation` |
| Generator | `build_runner`, `freezed`, `riverpod_generator`, `json_serializable` |

---

## 🎉 Sekarang Tinggal 3 Langkah:
1. `flutter create`
2. `dart generate.dart init`
3. `dart generate.dart page:home`

**Selesai!** 🎉  
Tinggal koding logic bisnis, struktur & boilerplate sudah otomatis.

```
