# FE Player 🎬

> Modern, clean, and high-performance **Futuristic White Glassmorphism Desktop & Web Video Player** built with **Flutter** & **C++ / `media_kit` (libmpv engine)**.

---

## 💎 Design System & UX Highlights

* **Aesthetic**: Clean White / Light Mode base with a futuristic glassmorphism style.
* **Background & Panels**: Frosted white acrylic glass (`#F8FAFC` at `0.75` opacity) with blur filters (`BackdropFilter` sigma 16), subtle border strokes (`#E2E8F0` at `0.5` opacity), and soft drop shadows.
* **Accent & Highlights**: Electric Blue (`#2563EB` / `#3B82F6`) for active states, timeline scrub fills, and glowing button effects.
* **Text & Icons**: Deep Slate / Charcoal (`#0F172A`) for crisp readability against light glass panels.

---

## ⚡ Micro-Interactions & Gestures

* **Auto-hiding Control Bar**: Bottom glass pill and title bar auto-hide after 2 seconds of mouse inactivity during playback.
* **Glass Hover & Glow**: Micro-animations on all buttons with a soft blue tint/glow on interaction.
* **Double-Tap / Click Rewind & Fast-Forward**: Left screen half rewinds 5s (`-5s`), right screen half forwards 5s (`+5s`) with glowing glass badges.
* **Frameless Drag Area**: Integrated with `window_manager` for custom frameless window dragging.
* **Keyboard Shortcuts**:
  * `Space`: Play / Pause toggle
  * `F` or `F11`: Fullscreen toggle
  * `M`: Mute / Unmute toggle
  * `Left Arrow` / `Right Arrow`: Rewind / Forward 5 seconds
  * `Up Arrow` / `Down Arrow`: Volume adjust (±5%)

---

## 🚀 How to Run

### 1. Windows Desktop (Native libmpv Hardware Accelerated)
```bash
cd /Users/rmacstudio2/Documents/fe_player
flutter pub get
flutter run -d windows
```

### 2. Web / Localhost Test
To test the UI layout and web player in your browser / localhost:
```bash
cd /Users/rmacstudio2/Documents/fe_player
flutter run -d chrome
# or start local web server
flutter run -d web-server --web-port=8080
```
