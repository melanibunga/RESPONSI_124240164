# Rick & Morty Character Explorer (Flutter)

## Cara menjalankan
1. Ekstrak zip, masuk ke foldernya.
2. Generate folder platform (android/ios) — file lib & pubspec tidak akan ditimpa:
   flutter create . --project-name rick_morty_explorer
3. Hapus test bawaan (opsional): rm test/widget_test.dart
4. flutter pub get
5. flutter run   (jalankan di Android/iOS/emulator; sqflite tidak mendukung web)

## Android: izin internet
`flutter create` sudah menambahkan izin INTERNET di AndroidManifest untuk build debug.
Untuk release, pastikan ada: <uses-permission android:name="android.permission.INTERNET"/>
