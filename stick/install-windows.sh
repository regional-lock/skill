#!/usr/bin/env bash
# Windows installer for the animation skills in this folder (run in Git Bash, or double-click INSTAL*.bat).
#   bash install-windows.sh            # installs every skill in skills/
#   bash install-windows.sh --voice    # + the voice package (always on when /stick-figure is the only skill)
# Safe to run again. Installs Python 3.12, ffmpeg and Node with winget when they are missing.
# Everything it prints is also saved to install-log.txt next to this script.
set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KIT="$ROOT/kit"
SKILLS_DEST="${CLAUDE_SKILLS_DIR:-$USERPROFILE/.claude/skills}"
LOG="$ROOT/install-log.txt"
exec > >(tee "$LOG") 2>&1
say()  { printf '\n\033[1;36m== %s\033[0m\n' "$*"; }
ok()   { printf '   \033[32mOK\033[0m %s\n' "$*"; }
fail() { printf '\n\033[1;31mGAGAL: %s\033[0m\nCatatan lengkap ada di: %s\n' "$*" "$(cygpath -w "$LOG")"; read -rp "Tekan Enter untuk keluar..." _; exit 1; }
LA="$(cygpath -u "$LOCALAPPDATA")"

HAS_GRAPH=0; [ -d "$ROOT/skills/graph" ] && HAS_GRAPH=1
HAS_STICK=0; [ -d "$ROOT/skills/stick-figure" ] && HAS_STICK=1
VOICE=0; [ "${1:-}" = "--voice" ] && VOICE=1
[ $HAS_STICK = 1 ] && [ "$(ls -d "$ROOT"/skills/*/ | wc -l)" -eq 1 ] && VOICE=1

case "$ROOT" in *" "*) fail "Folder ini ada di path yang mengandung spasi ($ROOT). Pindahkan ke misalnya D:\\animation-skills lalu jalankan lagi.";; esac

# ---------- 1. tools ----------
say "1/5 Cek Python, ffmpeg, Node"
command -v winget >/dev/null || fail "winget tidak ada. Update 'App Installer' dari Microsoft Store dulu."
PYEXE="$LA/Programs/Python/Python312/python.exe"
if [ ! -x "$PYEXE" ]; then
  echo "   memasang Python 3.12 ..."
  winget install --id Python.Python.3.12 -e --scope user --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
fi
[ -x "$PYEXE" ] || fail "Python 3.12 tidak terpasang."
ok "Python: $("$PYEXE" --version)"

FFBIN="$(ls -d "$LA"/Microsoft/WinGet/Packages/Gyan.FFmpeg*/ffmpeg-*/bin 2>/dev/null | head -1)"
if ! command -v ffmpeg >/dev/null && [ -z "$FFBIN" ]; then
  echo "   memasang ffmpeg ..."
  winget install --id Gyan.FFmpeg -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
  FFBIN="$(ls -d "$LA"/Microsoft/WinGet/Packages/Gyan.FFmpeg*/ffmpeg-*/bin 2>/dev/null | head -1)"
fi
[ -n "$FFBIN" ] && export PATH="$FFBIN:$PATH"
command -v ffmpeg >/dev/null || fail "ffmpeg tidak terpasang."
ok "ffmpeg"

if ! command -v npm >/dev/null; then
  echo "   memasang Node.js LTS ..."
  winget install --id OpenJS.NodeJS.LTS -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
  export PATH="/c/Program Files/nodejs:$PATH"
fi
command -v npm >/dev/null || fail "Node.js tidak terpasang. Tutup jendela ini, buka lagi, lalu jalankan ulang."
ok "Node $(node -v)"

# ---------- 2. link skills ----------
say "2/5 Menautkan skill ke $SKILLS_DEST"
mkdir -p "$SKILLS_DEST"
for d in "$ROOT"/skills/*/; do
  name=$(basename "$d"); dest="$SKILLS_DEST/$name"
  if [ -e "$dest" ]; then
    if [ "$(powershell -NoProfile -Command "(Get-Item -LiteralPath '$(cygpath -w "$dest")').LinkType" 2>/dev/null | tr -d '\r')" = "Junction" ]; then cmd //c rmdir "$(cygpath -w "$dest")" >/dev/null; else echo "   lewati /$name: sudah ada folder dengan nama itu"; continue; fi
  fi
  cmd //c mklink //J "$(cygpath -w "$dest")" "$(cygpath -w "${d%/}")" >/dev/null && ok "/$name"
done
# /stick-figure finds the kit through this file when it runs from the junction
[ $HAS_STICK = 1 ] && printf '%s\n' "$KIT" > "$ROOT/skills/stick-figure/engine/kitpath.txt"

# ---------- 3. kit ----------
say "3/5 Memasang Playwright + Chromium$([ $HAS_GRAPH = 1 ] && echo ', three.js, GSAP, HyperFrames')"
(cd "$KIT" && npm install --no-audit --no-fund --loglevel=error) || fail "npm install (cek koneksi internet)"
(cd "$KIT" && npx --yes playwright install chromium) || fail "playwright install chromium (cek koneksi internet)"
if [ $HAS_GRAPH = 1 ]; then
  mkdir -p "$KIT/vendor"
  [ -s "$KIT/vendor/gsap.min.js" ] || curl -fsSL https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js -o "$KIT/vendor/gsap.min.js" || fail "unduh GSAP"
  npx --yes hyperframes@0.8.34 --version >/dev/null 2>&1 || echo "   (HyperFrames akan diunduh saat render pertama)"
fi
ok "kit siap"

# ---------- 4. voice ----------
if [ $VOICE = 1 ]; then
  say "4/5 Paket suara (Kokoro + Parakeet), sekitar 1.3 GB, mohon sabar"
  [ -x "$KIT/.venv/Scripts/python.exe" ] || "$PYEXE" -m venv "$KIT/.venv" || fail "membuat venv"
  [ -e "$KIT/.venv/bin" ] || cmd //c mklink //J "$(cygpath -w "$KIT/.venv/bin")" "$(cygpath -w "$KIT/.venv/Scripts")" >/dev/null
  "$KIT/.venv/Scripts/python.exe" -m pip install -q --upgrade pip
  "$KIT/.venv/Scripts/python.exe" -m pip install -q numpy scipy soundfile kokoro-onnx sherpa-onnx || fail "pip install"
  M="$KIT/models"; mkdir -p "$M"
  [ -s "$M/kokoro-v1.0.onnx" ] || curl -fL -# -o "$M/kokoro-v1.0.onnx" https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/kokoro-v1.0.onnx || fail "unduh kokoro"
  [ -s "$M/voices-v1.0.bin" ] || curl -fL -# -o "$M/voices-v1.0.bin" https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0/voices-v1.0.bin || fail "unduh voices"
  if ! ls -d "$M"/sherpa-onnx-nemo-parakeet* >/dev/null 2>&1; then
    curl -fL -# -o "$M/p.tar.bz2" https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-nemo-parakeet-tdt-0.6b-v2-int8.tar.bz2 || fail "unduh parakeet"
    (cd "$M" && tar xjf p.tar.bz2 && rm -f p.tar.bz2) || fail "ekstrak parakeet"
  fi
  "$KIT/.venv/bin/python" -c "import kokoro_onnx, sherpa_onnx" || fail "tes paket suara"
  ok "paket suara siap"
else
  say "4/5 Paket suara dilewati (jalankan INSTAL-DENGAN-SUARA.bat untuk /stick-figure dan /zach-d-films)"
fi

# ---------- 5. test ----------
T="$ROOT/_tes"; mkdir -p "$T"
if [ $HAS_GRAPH = 1 ]; then
  say "5/5 Tes render /graph"
  printf '%s' '{"label":"Followers","values":[1,2,4,8,16,40,100],"final":100000}' > "$T/tes.graph.json"
  (cd "$T" && "$PYEXE" "$ROOT/skills/graph/build.py" tes.graph.json) || fail "tes render /graph"
  ok "video tes: $(cygpath -w "$T/tes.graph.mp4")"
fi
if [ $HAS_STICK = 1 ] && [ $VOICE = 1 ]; then
  say "5/5 Tes /stick-figure: suara, timing kata, satu gambar"
  R="$T/stick"; mkdir -p "$R"; cp -r "$ROOT/skills/stick-figure/engine/template/." "$R/"
  E="$SKILLS_DEST/stick-figure/engine"   # through the junction, the way Claude will call it
  (cd "$R" && "$KIT/.venv/bin/python" "$E/tools/tts_kokoro.py" >/dev/null && cp audio/vo_kokoro.wav audio/vo.wav \
     && "$KIT/.venv/bin/python" "$E/tools/align.py" audio/vo.wav | head -1 \
     && NODE_PATH="$KIT/node_modules" node "$E/tools/render.js" stills 1.5 >/dev/null) || fail "tes /stick-figure"
  [ -s "$R/stills/s_1.50.jpg" ] || fail "tes /stick-figure: gambar tidak terbentuk"
  ok "suara tes: $(cygpath -w "$R/audio/vo.wav")"
  ok "gambar tes: $(cygpath -w "$R/stills/s_1.50.jpg")"
fi

printf '\n\033[1;32mSELESAI.\033[0m Tutup lalu buka lagi Claude Code, kemudian ketik misalnya:\n'
[ $HAS_STICK = 1 ] && [ $VOICE = 1 ] && printf '   /stick-figure Why do cats always land on their feet?\n'
[ $HAS_GRAPH = 1 ] && printf '   /graph 0 to 10K followers in 6 months\n'
echo
read -rp "Tekan Enter untuk keluar..." _
