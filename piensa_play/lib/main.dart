import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/glossary_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/tutor_login_screen.dart';
import 'screens/tutor_dashboard_screen.dart';
import 'screens/manage_glossary_screen.dart';
import 'screens/add_glossary_term_screen.dart';
import 'screens/game_units_screen.dart';
import 'screens/game_detail_screen.dart';
import 'screens/game_play_screen.dart';
import 'screens/manage_games_screen.dart';
import 'screens/create_game_unit_screen.dart';
import 'screens/game_activities_map_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // If init fails (e.g., unsupported platform config), log but continue so UI isn't blank.
    // Firestore calls will throw later with a clearer message.
    // You can surface a banner or dialog if desired.
    debugPrint('Firebase init error: $e');
  }
  runApp(const PiensaPlayApp());
}

class PiensaPlayApp extends StatelessWidget {
  const PiensaPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PiensaPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(
          userId: 'temp',
          userName: 'Usuario',
          avatarIndex: 0,
          userTag: '000000',
        ),
        '/glossary': (context) => const GlossaryScreen(),
        '/settings': (context) => const SettingsScreen(
          userId: 'temp',
          userName: 'Usuario',
          avatarIndex: 0,
        ),
        '/progress': (context) => const ProgressScreen(
          userId: 'temp',
          userName: 'Usuario',
          avatarIndex: 0,
        ),
        '/tutor_login': (context) => const TutorLoginScreen(),
        '/tutor_dashboard': (context) => const TutorDashboardScreen(),
        '/manage_glossary': (context) => const ManageGlossaryScreen(),
        '/add_glossary_term': (context) => const AddGlossaryTermScreen(),
        '/game_units': (context) => const GameUnitsScreen(),
        '/game_detail': (context) => const GameDetailScreen(),
        '/game_activities_map': (context) => const GameActivitiesMapScreen(),
        '/game_play': (context) => const GamePlayScreen(),
        '/manage_games': (context) => const ManageGamesScreen(),
        '/create_game_unit': (context) => const CreateGameUnitScreen(),
      },
    );
  }
}