# FE Player 🎬

<p align="center">
  <img src="assets/icons/app_logo.png" width="120" height="120" alt="FE Player Logo" />
</p>

<p align="center">
  <b>Futuristic White Glassmorphism Video Player</b> built with Flutter & C++ (libmpv Hardware Engine).
</p>

<p align="center">
  <a href="https://github.com/pabeledp/FEPlayer/raw/main/dmg_output/FEPlayer-macOS.dmg">
    <img src="https://img.shields.io/badge/Download-macOS%20DMG%20(Universal)-2563EB?style=for-the-badge&logo=apple&logoColor=white" alt="Download macOS DMG" />
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/pabeledp/FEPlayer/releases">
    <img src="https://img.shields.io/badge/Download-Android%20APK-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Download Android APK" />
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/pabeledp/FEPlayer/releases">
    <img src="https://img.shields.io/badge/Download-Windows%20EXE-0078D6?style=for-the-badge&logo=windows&logoColor=white" alt="Download Windows EXE" />
  </a>
</p>

---

## 📥 Direct Downloads

| Platform | Download Link | Build Type | Features |
| :--- | :--- | :--- | :--- |
| 🍏 **macOS** | [**Download FEPlayer-macOS.dmg**](https://github.com/pabeledp/FEPlayer/raw/main/dmg_output/FEPlayer-macOS.dmg) | `.dmg` Installer (Apple Silicon & Intel) | Full libmpv 4K 60fps hardware acceleration, Acrylic Glass blur, Frameless drag, Touch Gestures |
| 🤖 **Android** | [**Download Android APK**](https://github.com/pabeledp/FEPlayer/releases) | `.apk` Package | Gesture controls, Dual Audio selector, Monospace HUD |
| 🪟 **Windows** | [**Download Windows Release**](https://github.com/pabeledp/FEPlayer/releases) | `.exe` Executable | Acrylic / Mica blur, 60fps libmpv engine, Frameless header |

---

## 💎 Design System & UX Highlights

* **Aesthetic**: Clean White / Light Mode base with a futuristic glassmorphism style.
* **Background & Panels**: Frosted white acrylic glass (`#F8FAFC` at `0.75` opacity) with blur filters (`BackdropFilter` sigma 16), subtle border strokes (`#E2E8F0` at `0.5` opacity), and soft drop shadows.
* **Accent & Highlights**: Electric Blue (`#2563EB` / `#3B82F6`) for active states, timeline scrub fills, and glowing button effects.
* **Text & Icons**: Deep Slate / Charcoal (`#0F172A`) for crisp readability against light glass panels.

---

## ⚡ Features & Micro-Interactions

* 📂 **VLC-Style Media Hub & Drawer (`L` key)**: Fast access to Playlist, Media Library, and Recent Media.
* 🌐 **Dual-Language & Multi-Audio Track Selector**: Switch between audio languages (e.g. English, Hindi, Bengali) on the fly.
* 💬 **Subtitle Track Manager**: Dynamic subtitle switching + load external `.srt` / `.vtt` files.
* 🔊 **Keyboard Sound Control & On-Screen HUD**: `Up / Down Arrow` adjusts volume in ±5% steps with an animated frosted glass HUD badge.
* 🖱️ **Instant Mouse Exit Auto-Hide**: Control bar and header instantly fade out when the mouse cursor leaves the video screen/window.
* ⏩ **Double-Tap Seek**: Double-click left/right screen half to rewind/forward 5 seconds with glowing feedback badges.
* 🎮 **Keyboard Shortcuts**:
  * `Space`: Play / Pause toggle
  * `Up / Down Arrow`: Volume adjust (±5%) + HUD
  * `Left / Right Arrow`: Seek 5 seconds (±5s)
  * `M`: Mute / Unmute
  * `L`: Toggle VLC Media Library Drawer
  * `F` or `F11`: Fullscreen toggle

---

## 🚀 Building from Source

### macOS Desktop
```bash
cd fe_player
./build_dmg.sh
```

### Windows Desktop
```bash
flutter pub get
flutter build windows --release
```

### Android APK
```bash
flutter build apk --release
```

### Web (Localhost)
```bash
flutter run -d chrome
```
