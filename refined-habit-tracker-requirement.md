# Smart Habit Tracker - Refined Requirement & Context

## 1. Project Overview
**Aim**: A Windows desktop GitHub history-style habit tracker.
**Tech Stack**: Flutter 3.12+
**Platform**: Windows Desktop (Support for 10/11, responsive for 720p to 4k)
**App Name**: SmartHabitTracker – Track your habit with ease

## 2. Core Dependencies
- **State Management**: `provider` (or `flutter_riverpod`)
- **Local Database**: `drift` & `sqlite3_flutter_libs` (for robust SQLite on Windows, Android, and iOS, allowing easy raw `.sqlite` data export and Drive sync) + `path_provider`
- **Preferences**: `shared_preferences` (for storing theme mode & first-time launch flag)
- **UI Elements**: `material_design_icons_flutter` (for habit icons), `flutter_colorpicker` (for custom colors).

## 3. Storage Strategy
- **`shared_preferences`**:
  - `is_first_time` (bool): If true, show Welcome Modal. Set to false after user creates their first habit.
  - `theme_mode` (int): 0 to 3 (representing the 4 theme modes).
- **SQLite (`drift`) Tables**:
  - `Habits` Table:
    - `id` (Int, Auto-Increment)
    - `name` (Text, Unique)
    - `description` (Text, max 50 chars, Nullable)
    - `iconCodePoint` (Int)
    - `colorHex` (Int)
    - `isLifelong` (Bool)
    - `startDate` (DateTime)
    - `endDate` (DateTime, Nullable)
  - `HabitCompletions` Table (1-to-Many relation with Habits):
    - `id` (Int, Auto-Increment)
    - `habitId` (Int, Foreign Key to Habits.id)
    - `completedDate` (DateTime, Unique constraint together with habitId)

## 4. UI/UX & Theming Requirements
- **Design Language**: Strict Material UI, transparency effects, consistent theme, heavy visual effects (gradients, shadows, smooth transitions) for a modern, rich look.
- **Theme Modes (4 Options)**:
  1. Dark mode + Black/Grey accents
  2. Dark mode + Blue/Purple accents
  3. Light mode + White theme
  4. Light mode + Greenish accents

## 5. Application Flow & Features

### A. Initial Launch
- Greet the user with a modal box.
- Check if habits exist. If 0 habits, force user to create at least one before accessing the Home Screen.

### B. Habit Creation
- **Constraints**: One habit at a time, unique name required.
- **Inputs**:
  - Name
  - Description (optional, max 50 chars).
  - Duration: Lifelong (default) OR start/end date (start defaults to current date).
- **Auto-Assignments**: 
  - Auto-assign a Material icon (user can click to change).
  - Auto-assign a color from 10 default colors (user can click to open color picker to choose any custom color).

### C. Global Views Navigation
- The app should provide navigation (e.g., a Sidebar or Top Tab Bar) to switch between different global views for all habits:
  1. **Home / 365 Days View (Default)**: Shows the dashboard with the full 365-day GitHub-style graph.
  2. **Weekly View Page**: A separate page showing the current week for all habits (grey inactive days, colored active days). **Interaction**: Clicking on a specific day for a habit directly toggles its completion status for that day.
  3. **Monthly View Page**: A separate page showing the current month for all habits (grey inactive days, colored active days). **Interaction**: Clicking on a specific day for a habit directly toggles its completion status for that day.

### D. Home Screen Dashboard (365 Days View)
- Show all habits divided into 3 toggleable sections:
  1. **Ongoing** (Default ON): Start date $\le$ today AND (end date $>$ today OR lifelong).
  2. **Upcoming** (Default OFF): Start date $>$ today.
  3. **Past** (Default OFF): End date $<$ today.

### E. Habit Card Component
- **Layout**: Habit Icon, Name, Button to mark "Completed today", and the view-specific graph (e.g., 365-day graph on Home, 7-day graph on Weekly view).
- **Interactions**: 
  - Clicking "Completed today" updates the graph instantly with the habit's assigned color.
  - Clicking the widget opens the **Habit Calendar View**.

### F. Habit Calendar View (Detailed)
- Opened upon clicking a habit card.
- Displays full month calendar with Prev/Next month toggles.
- Highlights completed days.
- User can click any day in the past or present to toggle completion status manually.

## 6. Testing & Quality
- Responsive UI across window resizing.
- Unit and Integration tests for Habit creation, constraint validation, and state changes.
- Sanity checks on date logic and edge cases (e.g., crossing month/year boundaries).
