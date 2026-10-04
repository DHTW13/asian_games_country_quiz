# 亞洲運動會國家測驗 · Asian Games Country Quiz

Flutter Web + Android game for the 2026 Aichi-Nagoya Asian Games 45 NOCs.

## V1.1 improvements

- 45 local flag SVG assets replaced with higher-detail vector flag artwork.
- Myanmar, Bhutan, Brunei, Kazakhstan, Oman, Sri Lanka, Turkmenistan and other emblem-heavy flags are no longer simple geometric placeholders.
- Larger flag preview and cleaner outline card.
- More polished map panel with subtle map grid and web mouse cursor feedback.
- Same 45-question logic and local GeoJSON remain unchanged.

## UI design

- 國家輪廓題目 · Country outline question
- 可點擊亞洲地圖 · Interactive Asia map
- 本地國旗 SVG · Local flag SVG
- 本地國家 SVG · Local country outline SVG
- 45 NOC local GeoJSON Polygon/MultiPolygon
- 中英文並行 · Chinese + English throughout the UI
- 45 questions, one per NOC, randomized per game
- Web and Android share the same Flutter codebase

## Run

```bash
flutter pub get
flutter run -d chrome
```

## Build Web

```bash
flutter build web --release
```

## Build Android APK

```bash
flutter build apk --release
```

All runtime geography and flag assets are local under `assets/`; the app does not need a CDN for quiz assets.


## v1.3 changes
- Removed flag display from the question card.
- Shows NOC/representative team name directly.
- Preserves map aspect ratio instead of stretching it.
- Adds enlarged hit areas for small countries/territories.
- Adds a cursor/tap-following local magnifier.
