# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-05-25

### Added
- **Initial Release** of the Smart Habit Tracker!
- **Yearly View**: A comprehensive yearly heatmap of all your habits.
  - Added support for both "Calendar" (aligned to days of the week) and "Consecutive" (straight continuous boxes) layouts.
  - Hover tooltips for specific date insights.
  - Day streak calculation.
- **Dynamic Theming System**:
  - Classic Light and Dark modes.
  - **Neon Mode**: Immersive ambient glows behind cards.
  - **Glassmorphism**: Frosted glass effects for a premium UI feel.
  - **Funky Mode**: Retro 3D layouts with offset shadows.
- **Local Data Backup**: 
  - Ability to export your SQLite habit data to a secure backup file.
  - Import existing backups safely.
- **Windows Desktop Support**:
  - Fully optimized for Windows environments.
  - Native MSIX installer generation.
  - Custom taskbar and window icons.

### Changed
- Re-architected `github_grid.dart` to support automated scrolling to the current week.
- Refined color palettes to ensure high contrast and readability across all 10 theme variations.
