# Foxio Design System — "Cozy Fox Paper"

Panduan visual resmi untuk proyek **Foxio** (*Grow your day, one task at a time*).
Terinspirasi dari estetika hangat, tenang, dan *low-stress* milik **DailyBean**, **TimeGrow**, **Can Journals**, dan **Writeway**, dipadukan dengan karakter maskot **Mini Fox**.

---

## 1. Filosofi Visual
- **Warm Digital Paper**: Menghindari putih dingin (`#FFFFFF` murni sebagai canvas) dan hitam pekat (`#000000`). Menggunakan latar krem kertas hangat agar nyaman dilihat mahasiswa setiap hari.
- **Earth & Muted Tones**: Warna jenuh rendah (*desaturated*) untuk mengurangi beban kognitif (*low cognitive load*).
- **Soft Geometry**: Sudut membulat (`borderRadius: 14–18px`), border lembut, dan tanpa bayangan (*shadow*) yang keras.
- **Lightly Gamified**: Warna hijau sage untuk progres tumbuh dan kuning madu untuk streak/level agar terasa memuaskan tanpa terasa berlebihan.

---

## 2. Color Palette (Locked)

### Brand & Mascot (Mini Fox)
| Token | Nama | HEX | Flutter Constant | Penggunaan |
|---|---|---|---|---|
| Primary | Muted Fox Terracotta | `#E07A5F` | `AppColors.primary` | Tombol utama, CTA, active tab, aksen Mini Fox |
| Primary Light | Blush Peach | `#FBECE7` | `AppColors.primaryLight` | Background avatar Mini Fox, highlight lembut |
| Primary Dark | Deep Terracotta | `#C86248` | `AppColors.primaryDark` | State pressed / teks di atas `primaryLight` |

### Growth & Gamification
| Token | Nama | HEX | Flutter Constant | Penggunaan |
|---|---|---|---|---|
| Secondary / Success | Muted Sage Green | `#81B29A` | `AppColors.secondary` / `AppColors.success` | Centang Habit selesai, progress ring, indikator tumbuh |
| Secondary Light | Mint Whisper | `#EAF4EE` | `AppColors.secondaryLight` | Background status selesai / hari produktif di kalender |
| Streak / Points | Warm Honey | `#E9B872` | `AppColors.streak` | Ikon api streak, bintang level, poin |
| Streak Light | Butter Cream | `#FDF5E6` | `AppColors.streakLight` | Badge streak & notifikasi Level Up |

### Backgrounds & Surfaces
| Token | Nama | HEX | Flutter Constant | Penggunaan |
|---|---|---|---|---|
| Background | Warm Paper Cream | `#FAF7F2` | `AppColors.background` | Canvas / Scaffold utama semua halaman |
| Surface | Pure Warm White | `#FFFFFF` | `AppColors.surface` | Card Todo, Card Habit, Modal, Input aktif |
| Surface Variant | Soft Sand | `#F3EDE4` | `AppColors.surfaceVariant` | Chip kategori, tab bar background, empty state card |

### Typography (Warm Neutrals)
| Token | Nama | HEX | Flutter Constant | Penggunaan |
|---|---|---|---|---|
| Text Primary | Warm Charcoal | `#2F2A26` | `AppColors.textPrimary` | Judul halaman, nama task, angka statistik |
| Text Secondary | Warm Taupe | `#78716C` | `AppColors.textSecondary` | Deskripsi task, subjudul, tanggal |
| Text Muted | Soft Stone | `#A8A29E` | `AppColors.textMuted` | Placeholder input, teks selesai (strikethrough) |

### Borders & Semantic Status
| Token | Nama | HEX | Flutter Constant | Penggunaan |
|---|---|---|---|---|
| Border | Warm Oat | `#E7E0D6` | `AppColors.border` | Garis tepi input field & checkbox |
| Border Subtle | Soft Linen | `#EFEAE2` | `AppColors.borderSubtle` | Garis tepi card & divider halus |
| Error | Dusty Coral | `#D66853` | `AppColors.error` | Validasi error, aksi hapus (tetap lembut) |
| Info | Soft Slate Blue | `#6B9AC4` | `AppColors.info` | Status sync / informasi ringan |

---

## 3. Tipografi
- **Font Family**: `Inter` (via `google_fonts`)
- **Hierarchy**:
  - `displayLarge`: Bold (700) — Judul splash / angka statistik besar
  - `titleLarge`: Bold (700), 20px — Judul AppBar & section utama
  - `titleMedium`: SemiBold (600), 16px — Judul Card / Todo / Habit
  - `bodyLarge`: Regular (400), 15px — Konten utama
  - `bodyMedium`: Regular (400), 14px — Deskripsi & metadata
  - `bodySmall`: Regular (400), 12px — Label kecil, tanggal, badge

---

## 4. Panduan Aset Blender (Mini Fox)
Agar render 3D Mini Fox menyatu sempurna dengan UI:
- **Warna Bulu Utama**: Arahkan ke *warm terracotta/apricot* mendekati `#E07A5F` – `#EB8A64` (hindari oranye neon).
- **Warna Aksen Bulu (Perut/Pipi/Ujung Ekor)**: Krem hangat mendekati `#FAF7F2`.
- **Lighting**: Soft studio warm light (hindari bayangan hitam pekat; gunakan *ambient occlusion* lembut).
- **Export**: PNG transparan, resolusi 1024×1024px (akan di-scale otomatis oleh Flutter).
