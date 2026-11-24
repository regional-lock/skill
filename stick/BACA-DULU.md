# /stick-figure: Skill Video Stickman untuk Claude Code (versi Windows)

Ketik satu pertanyaan, misalnya `/stick-figure Why do cats always land on their feet?`, dan Claude akan membuatkan **video explainer stickman vertikal 30–45 detik** (1080×1920, siap untuk Reels/Shorts/TikTok). Isinya lengkap:
- naskah yang dicek faktanya,
- dunia kartun dan tokoh stickman berekspresi,
- transisi whip,
- caption 1–2 kata yang pas dengan suara,
- suara narator,
- musik dan efek suara.

Semuanya dibuat dengan kode dan dirender di komputermu sendiri. Tidak ada AI gambar, tidak ada konektor, dan tidak ada biaya per video.

> **Kredit:** skill ini dibuat oleh **Artem Novitckii** dan dibagikan dengan lisensi MIT (lihat file `LICENSE`).
> Repo asli: https://github.com/artemnovitckii/claude-animation-skills
> Paket ini skill yang sama ditambah penyesuaian untuk Windows, installer satu klik, dan panduan berbahasa Indonesia.

---

## Yang dibutuhkan
- **Windows 10/11**
- **Claude Code** sudah terpasang dan bisa dipakai
- **Git for Windows** (https://git-scm.com/download/win). Biasanya sudah terpasang bersama Claude Code.
- Ruang kosong sekitar **2 GB**, karena model suara sekitar 1,3 GB
- Koneksi internet saat instalasi

Python, ffmpeg, dan Node.js akan **dipasang otomatis** kalau belum ada.

## Cara instal (tanpa perlu membuka Claude)
1. **Ekstrak ZIP** ke folder yang path-nya **tanpa spasi**, misalnya `D:\stick-figure`.
   - Jangan dijalankan langsung dari dalam ZIP.
   - Setelah terpasang, **folder ini jangan dipindah atau dihapus**, karena skill-nya terhubung ke folder ini.
2. Klik dua kali **`INSTAL.bat`**.
   - Kalau muncul peringatan biru "Windows protected your PC", klik **More info → Run anyway**.
   - Kalau Windows meminta izin (UAC), klik **Yes**.
3. Tunggu sampai muncul tulisan **SELESAI**. Prosesnya sekitar 5–15 menit, tergantung internet. Di akhir, installer membuat suara tes dan gambar tes di folder `_tes\stick`.
4. **Tutup lalu buka lagi Claude Code.**

## Cara pakai
Ketik di Claude Code:
```
/stick-figure Why did pirates wear eye patches?
```
Alurnya:
1. Claude **menulis naskah** (sekitar 110–120 kata, kira-kira 40 detik) dan **menunjukkannya dulu ke kamu**.
2. Setelah kamu setuju, Claude membuat suara, menyusun adegan, mengecek beberapa gambar contoh, lalu merender.
3. Hasilnya berupa file `.mp4` di folder reel yang dibuat Claude.

Lama render sekitar **5–10 menit** untuk video 40 detik, tergantung PC.

Ide topik yang cocok: pertanyaan "kenapa" atau "what if" yang punya jawaban mengejutkan. Contohnya *Why do planes fly?*, *What if the Moon disappeared?*, atau *Why is the sky blue?*

## Soal suara (penting)
- Suara gratis bawaan (**Kokoro**) hanya **bahasa Inggris**. Pilihan suaranya antara lain `am_michael` (default), `am_adam`, `bm_george` (British), dan `af_heart` (perempuan). Minta saja ke Claude: *"pakai suara bm_george"*.
- **Rekaman sendiri bisa dipakai**, tapi **harus bahasa Inggris** dan dibaca persis sesuai naskah. Dengan narasi bahasa Indonesia, caption dan adegannya akan meleset dari suara.
- Suara ElevenLabs juga didukung, asal kamu punya API key sendiri (`ELEVENLABS_API_KEY`).

## Kalau ada masalah
- **Instalasi berhenti dengan tulisan GAGAL:** tutup jendelanya, cek koneksi internet, lalu klik `INSTAL.bat` lagi. Script ini aman dijalankan berulang.
- **Butuh bantuan:** kirim file `install-log.txt` dari folder ini ke admin. Semua yang tampil saat instalasi tercatat di sana.
- **Skill tidak muncul:** pastikan Claude Code sudah ditutup lalu dibuka lagi.
- **Claude mengetik `python3` lalu Microsoft Store terbuka:** minta Claude memakai `python`.

## Apa yang diubah dari versi asli
- `engine/make.sh`: path ffmpeg dibuat aman untuk Windows, dan lokasi `kit` tetap ditemukan walaupun skill dipanggil lewat folder tautan.
- `SKILL.md`: `python3` diganti `python`.
- Tambahan: `install-windows.sh`, `INSTAL.bat`, dan panduan ini.
