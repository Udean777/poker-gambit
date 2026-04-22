# 🎨 Game Assets Checklist & Resources

Dokumen ini berisi daftar aset yang dibutuhkan untuk pengembangan game **Poker Gambit** serta sumber daya gratis untuk mendapatkannya.

---

## 🖼️ Aset Visual (Images/SVGs)

Simpan di direktori: `assets/images/`

| Status | Aset               | Deskripsi                                      | Format  |
| :----: | :----------------- | :--------------------------------------------- | :------ |
|  [ ]   | **Full Card Deck** | 52 kartu (As - King, semua kembang)            | PNG/SVG |
|  [ ]   | **Card Back**      | Satu desain untuk sisi belakang kartu          | PNG/SVG |
|  [ ]   | **Suit Icons**     | Ikon terpisah: Spades, Hearts, Diamonds, Clubs | SVG     |
|  [ ]   | **Table Texture**  | Tekstur kain meja hijau/felt                   | PNG     |
|  [ ]   | **Avatars**        | Gambar profil untuk USER dan AI MASTER         | PNG/SVG |
|  [ ]   | **UI Icons**       | Pause, Help, Sound On/Off, Lock, Trophy        | SVG     |
|  [ ]   | **Game Logo**      | Desain logo judul "Poker Gambit"               | PNG/SVG |

### 🔗 Sumber Visual Gratis:

- **[Kenney Board Game Pack](https://kenney.nl/assets/boardgame-pack)** (Sangat Direkomendasikan)
- **[OpenGameArt - Playing Cards](https://opengameart.org/content/playing-cards-vector-png)**
- **[Itch.io Game Assets](https://itch.io/game-assets/free/tag-cards)**

---

## 🔊 Aset Audio (SFX & BGM)

Simpan di direktori: `assets/audio/`

| Status | Aset              | Deskripsi                         | Format  |
| :----: | :---------------- | :-------------------------------- | :------ |
|  [ ]   | **Card Shuffle**  | Suara kartu sedang dikocok        | WAV     |
|  [ ]   | **Card Deal**     | Suara kartu dibagikan/digeser     | WAV     |
|  [ ]   | **Card Flip**     | Suara kartu diletakkan di meja    | WAV     |
|  [ ]   | **Button Click**  | Suara UI saat menekan tombol menu | WAV     |
|  [ ]   | **Win Jingle**    | Musik pendek selebrasi kemenangan | WAV/MP3 |
|  [ ]   | **Lose Jingle**   | Suara/musik pendek saat kalah     | WAV/MP3 |
|  [ ]   | **BGM**           | Musik latar (Jazz/Lounge/Casino)  | MP3     |
|  [ ]   | **Timer Ticking** | Detak jam untuk tekanan waktu     | WAV     |

### 🔗 Sumber Audio Gratis:

- **[ZapSplat - Playing Cards SFX](https://www.zapsplat.com/sound-effect-category/playing-cards/)**
- **[Kenney Digital Audio](https://kenney.nl/assets/digital-audio)** (Untuk UI SFX)
- **[Pixabay Music](https://pixabay.com/music/search/lounge/)** (Untuk BGM)
- **[Freesound.org](https://freesound.org/)**

---

## 💡 Tips

1. **Penerapan di Kode**: Daftarkan semua aset baru di file `pubspec.yaml` agar bisa terbaca oleh Flutter.
2. **Optimasi**: Gunakan SVG sebisa mungkin untuk ikon agar tetap tajam di resolusi layar manapun.
3. **Format**: Gunakan `.wav` untuk efek suara pendek (SFX) guna mengurangi delay suara.
