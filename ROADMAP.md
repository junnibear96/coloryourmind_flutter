# Color Your Mind — Roadmap

This project is already beyond an “empty Flutter template”: it has a working gallery (`IntroPage`) and a full drawing experience (`ColoringPage`) with multiple tools, responsive layouts, export, and a simple EN/KR localization toggle.

## Current State (as implemented)

**App flow**
- `IntroPage`: gallery-like home with search, category carousels, and “My Drawings” based on saved exports
- `ColoringPage`: drawing canvas + tool panel (desktop side panel, mobile bottom controls)

**Implemented features**
- Brush + eraser drawing on a canvas (`DrawnLine`)
- Multiple brush styles (basic/soft/marker/pencil/airbrush/crayon)
- Brush size via slider + numeric input
- Default palette + custom colors dialog
- Undo/redo for strokes
- Reset/clear canvas
- Export to PNG/JPG via download (web) / platform downloader abstraction
- Basic EN/KR strings via `tr(ko, en)` and a locale toggle

**Known gaps (already visible in code)**
- `DrawingTool.fill`, `DrawingTool.colorPicker`, `DrawingTool.shape`, `DrawingTool.text` exist but are not fully implemented
- Shape fill state isn’t currently persisted/represented in export (`shapeColors` is passed as `{}` in export)
- App state is mostly local to widgets + a couple global `ValueNotifier`s (locale, uploaded images)

---

## Roadmap Overview

The roadmap is written as milestones you can complete in order. If you want, we can convert these into GitHub Issues (one per bullet) later.

### Milestone 1 — Foundation & Cleanup (P0)
Goal: make the code easier to change without breaking UI.

- Documentation refresh: describe real screens/features (done in docs updates)
- Split `ColoringPage` into smaller units:
  - `ColoringController` (state + actions: undo/redo/save)
  - `ToolPanel` widget (UI only)
  - `CanvasViewport` widget (gestures + painter)
- Introduce a single state management approach (pick one):
  - Minimal: `ChangeNotifier` + `InheritedNotifier`
  - Scalable: Riverpod
- Add a small “app-level” model layer for:
  - `DrawingDocument` (lines, objects, background, transforms)
  - serialization (save/load)

**Definition of done**
- `ColoringPage` is mostly UI wiring; logic lives in a controller
- Unit tests can cover controller actions (undo/redo/save)

### Milestone 2 — Coloring Tools v1 (P1)
Goal: the tool set feels complete for typical users.

- Implement **Color Picker** (tap on canvas to pick color)
- Implement **Fill**:
  - Option A (simple): fill a tapped shape region (`ShapeData`) instead of true flood fill
  - Option B (advanced): pixel flood fill for bitmap backgrounds
- Shape fill tracking: maintain `Map<int, Color> shapeColors` in state and use it in export
- Improve eraser behavior (optional): “erase strokes” vs painting white, depending on desired UX

**Definition of done**
- Fill + picker work on mobile + desktop
- Exports reproduce filled shapes and strokes

### Milestone 3 — Content & Gallery (P1)
Goal: user can bring their own pages and manage results.

- Add “Import image” / “Add page” (you already have `file_picker` dependency)
- Add lightweight metadata for drawings:
  - title, created time, format
  - optional tags/category
- Improve “My Drawings” persistence (currently it’s only in-memory)

**Definition of done**
- After restart, “My Drawings” still shows prior exports

### Milestone 4 — Persistence & Sharing (P2)
Goal: export and share works naturally on each platform.

- Mobile: save to gallery + share intent
- Desktop: save-to-file dialog
- Web: download + optional “copy to clipboard”

**Definition of done**
- Each platform’s export feels native

### Milestone 5 — Quality, Performance, Release (P2)
Goal: stability + store readiness.

- Performance: avoid excessive `setState` during drawing (throttle / use `ValueNotifier` for points)
- Accessibility: semantic labels and large-tap targets
- CI: run tests + `flutter analyze`
- App icons/splash

---

## Suggested Project Organization (non-breaking, incremental)

You can keep the current folders, but as the app grows, a feature-first layout will stay cleaner:

- `lib/core/` — app-wide helpers (localization wrapper, theme, platform utilities)
- `lib/features/gallery/` — intro/home, category carousel, image selection/import
- `lib/features/coloring/` — coloring screen, controller, canvas painter, tools UI
- `lib/models/` — pure data models (`ColoringImage`, `DrawnLine`, etc.)
- `lib/platform/` — download/save/share abstractions (web vs mobile)

This can be done file-by-file without rewriting everything.

---

## Immediate Next Steps (recommended order)

1. Track `shapeColors` in `ColoringPage` state and use it for exports
2. Implement simple shape fill (tap shape -> fill color)
3. Persist “My Drawings” locally (e.g., `shared_preferences` + base64 thumbnails, or a file-based store)
