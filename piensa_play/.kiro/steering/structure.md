# Project Structure

## Core Application Code (`lib/`)

### Entry Point
- `main.dart` - Application entry point, Firebase initialization, route configuration

### Screens (`lib/screens/`)
All UI screens organized by feature:

**Authentication & Onboarding:**
- `welcome_screen.dart` - Initial landing page with mascot
- `login_screen.dart` - Student profile creation with avatar selection
- `tutor_login_screen.dart` - Tutor authentication

**Student Features:**
- `home_screen.dart` - Main student dashboard
- `game_units_screen.dart` - List of available game units
- `game_detail_screen.dart` - Individual game unit details
- `game_activities_map_screen.dart` - Visual map of activities within a unit
- `game_play_screen.dart` - Active gameplay interface
- `activity_completion_screen.dart` - Activity completion feedback and results
- `unit_completion_screen.dart` - Unit completion celebration and rewards
- `final_exam_screen.dart` - Multi-question exam for unit assessment
- `fake_news_detector_screen.dart` - Fake news detection activities
- `stereotype_breaker_screen.dart` - Stereotype identification and transformation activities
- `word_path_screen.dart` - Word classification activities (hurtful vs constructive)
- `game_instructions_screen.dart` - Activity instructions and rules explanation
- `activity_intro_screen.dart` - Narrative introductions for activities
- `glossary_screen.dart` - Browse educational terms
- `progress_screen.dart` - Student progress tracking
- `settings_screen.dart` - User settings

**Tutor Features:**
- `tutor_dashboard_screen.dart` - Tutor control panel
- `manage_games_screen.dart` - Game unit management
- `create_game_unit_screen.dart` - Create/edit game units
- `manage_glossary_screen.dart` - Glossary management
- `add_glossary_term_screen.dart` - Add/edit glossary terms
- `game_form_dialog.dart` - Dialog for game configuration

### Utilities (`lib/utils/`)
- `app_styles.dart` - Centralized styling (colors, text styles, button styles, decorations)
- `firebase_service.dart` - Firebase/Firestore data access layer

### Widgets (`lib/widgets/`)
Reusable UI components for consistent design:
- `feedback_popup.dart` - Correct/incorrect feedback dialogs
- `hint_popup.dart` - Hint dialogs for activities
- `progress_bar_widget.dart` - Linear and circular progress indicators
- `score_card_widget.dart` - Score display and mission summary cards
- `activity_button_widget.dart` - Standardized buttons (primary, secondary, success, danger, outline)
- `scenario_card_widget.dart` - Scenario cards for stereotype activities
- `learning_points_widget.dart` - Learning points and clue lists
- `widgets.dart` - Index file for easy imports

### Firebase
- `firebase_options.dart` - Platform-specific Firebase configuration

## Assets (`assets/`)
- `image-removebg-preview 1.png` - Main mascot character
- `Vector.png`, `Vector (2).png`, `Vector (3).png`, `Vector (4).png` - Avatar options
- `image 2.png` - Additional asset

## Platform-Specific Code

### Android (`android/`)
- `app/build.gradle.kts` - Android build configuration
- `app/google-services.json` - Firebase Android configuration
- `app/src/main/AndroidManifest.xml` - Android manifest

### iOS (`ios/`)
- `Runner/` - iOS app configuration
- `Runner.xcodeproj/` - Xcode project files

### Web (`web/`)
- `index.html` - Web entry point
- `icons/` - PWA icons

### Windows (`windows/`)
- Native Windows runner code

### Linux (`linux/`)
- Native Linux runner code

### macOS (`macos/`)
- Native macOS runner code

## Configuration Files
- `pubspec.yaml` - Dependencies and asset declarations
- `analysis_options.yaml` - Dart analyzer configuration
- `firebase.json` - Firebase project configuration

## Architectural Patterns

### Navigation
- Named routes defined in `main.dart`
- Route parameters passed via constructor arguments

### State Management
- StatelessWidget for static screens
- StatefulWidget for interactive screens
- No external state management library (using built-in Flutter state)

### Data Layer
- `FirebaseService` class provides static methods for all Firestore operations
- Streams for real-time data (glossary, game units, progress)
- Async/await for one-time operations (create, update, delete)

### Styling
- Centralized in `AppStyles` class
- Consistent color palette with hex values
- Reusable button styles, text styles, and decorations
- Spanish as primary language in UI text
