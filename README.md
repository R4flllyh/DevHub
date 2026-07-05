# DevHub 🚀

[![Flutter Version](https://img.shields.io/badge/Flutter-%E2%89%A53.0.0-02569B?logo=flutter)](https://flutter.dev)
[![Dart Version](https://img.shields.io/badge/Dart-%E2%89%A53.0.0-0175C2?logo=dart)](https://dart.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

**DevHub** adalah aplikasi _news aggregator_ seluler modern dan minimalis yang dirancang khusus untuk para developer guna memantau tren teknologi terbaru, berita utama, dan wawasan editorial secara _real-time_.

Aplikasi ini dibangun dengan fokus pada performa yang mulus, antarmuka editorial premium bergaya majalah, dan pemisahan kode yang bersih.

---

## ✨ Fitur Utama

- **Editorial Feed UI**: Antarmuka bersih, minimalis, dan berfokus penuh pada kenyamanan membaca konten teknis.
- **Infinite Scroll / Lazy Loading**: Memuat artikel secara dinamis saat pengguna menggulir ke bawah guna menghemat kuota dan memori.
- **Premium Shimmer Loading**: Menggantikan _spinner/circular indicator_ konvensional dengan efek _skeleton loading_ animasi abu-abu yang bergerak statis meniru bentuk layout artikel asli.
- **Dev.to API Integration**: Data artikel yang akurat dan selalu diperbarui langsung dari ekosistem developer global.

---

## 🏗️ Arsitektur Proyek

Proyek ini menerapkan **Layered Architecture (Pemisahan Tanggung Jawab)** sebagai fondasi transisi menuju _Clean Architecture murni_:

```text
lib/
├── data/
│   ├── models/       # Cetak biru data (ArticleModel) & parsing JSON
│   └── providers/    # Manajemen koneksi HTTP ke REST API
└── presentation/
    ├── pages/        # Halaman utama aplikasi (UI Screen)
    └── widgets/      # Komponen UI modular yang dapat digunakan kembali (Shimmer, dll)
```
