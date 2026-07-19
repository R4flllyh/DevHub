# DevHub 🚀

[![Flutter Version](https://img.shields.io/badge/Flutter-%E2%89%A53.0.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%E2%89%A53.0.0-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**DevHub** adalah aplikasi _news aggregator_ seluler modern dan minimalis yang dirancang khusus untuk para developer guna memantau tren teknologi terbaru, berita utama, dan wawasan editorial secara _real-time_.

Aplikasi ini dibangun menggunakan prinsip **Clean Architecture** murni untuk memastikan pemisahan tanggung jawab yang ketat, kode yang mudah diuji (_testable_), serta skalabilitas jangka panjang.

---

## ✨ Fitur Utama

- **Editorial Feed UI**: Antarmuka bersih, minimalis, dan berfokus penuh pada kenyamanan membaca konten teknis dengan penanganan render Markdown yang optimal.
- **Infinite Scroll / Lazy Loading (Pagination)**: Memuat artikel secara dinamis menggunakan `ScrollController` bawaan saat pengguna menggulir ke bawah guna menghemat kuota dan memori, lengkap dengan pencegahan _RangeError overflow_.
- **Independent Discussion Section**: Fitur komentar artikel yang responsif dan terisolasi per item dengan mekanisme _Expand/Collapse_ ("Read more" / "Show less") otomatis menggunakan `TextPainter`.
- **Premium Shimmer Loading**: Menggantikan _spinner konvensional_ saat inisialisasi awal dengan efek _skeleton loading_ animasi yang meniru bentuk layout asli.
- **Dev.to API Integration**: Data artikel yang akurat, pembersihan otomatis dari _Liquid Tags_ bawaan, dan sinkronisasi data langsung dari ekosistem developer global.

---

## 🏗️ Arsitektur Proyek

Proyek ini sepenuhnya menerapkan **Clean Architecture (Data, Domain, Presentation Layers)** dengan alur ketergantungan satu arah yang ketat (Dependency Inversion):

```text
lib/
├── data/
│   ├── datasources/  # Sumber data mentah (Remote API HTTP Client)
│   ├── models/       # Cetak biru data (JSON Parsing & Serialization)
│   └── repositories/ # Implementasi konkrit dari kontrak repositori domain
├── domain/
│   ├── entities/     # Aturan bisnis inti / model data murni Dart
│   ├── repositories/ # Kontrak interface (abstraksi) untuk layer data
│   └── usecases/     # Logika bisnis spesifik per fitur aplikasi
└── presentation/
    ├── blocs/        # Manajemen state reaktif menggunakan Flutter BLoC (Feed, Detail, Comment)
    ├── pages/        # Halaman utama aplikasi (UI Screens)
    └── widgets/      # Komponen UI modular (Shimmer, CommentItemWidget, dll)
```
