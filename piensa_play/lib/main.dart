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
import 'screens/activity_completion_screen.dart';
import 'screens/unit_completion_screen.dart';
import 'screens/final_exam_screen.dart';
import 'screens/fake_news_detector_screen.dart';
import 'screens/stereotype_breaker_screen.dart';
import 'screens/word_path_screen.dart';
import 'screens/game_instructions_screen.dart';
import 'screens/activity_intro_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
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
      onGenerateRoute: (settings) {
        // Manejo centralizado de argumentos para evitar pantallas negras
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        
        Widget builder;
        switch (settings.name) {
          case '/':
            builder = const WelcomeScreen();
            break;
          case '/login':
            builder = const LoginScreen();
            break;
          case '/home':
            builder = HomeScreen(
              userId: args['userId'] ?? 'temp',
              userName: args['userName'] ?? 'Usuario',
              avatarIndex: args['avatarIndex'] ?? 0,
              userTag: args['userTag'] ?? '000000',
            );
            break;
          case '/glossary':
            builder = const GlossaryScreen();
            break;
          case '/settings':
            builder = SettingsScreen(
              userId: args['userId'] ?? 'temp',
              userName: args['userName'] ?? 'Usuario',
              avatarIndex: args['avatarIndex'] ?? 0,
            );
            break;
          case '/progress':
            builder = ProgressScreen(
              userId: args['userId'] ?? 'temp',
              userName: args['userName'] ?? 'Usuario',
              avatarIndex: args['avatarIndex'] ?? 0,
            );
            break;
          case '/tutor_login':
            builder = const TutorLoginScreen();
            break;
          case '/tutor_dashboard':
            builder = const TutorDashboardScreen();
            break;
          case '/manage_glossary':
            builder = const ManageGlossaryScreen();
            break;
          case '/add_glossary_term':
            builder = const AddGlossaryTermScreen();
            break;
          case '/game_units':
            builder = const GameUnitsScreen();
            break;
          case '/game_detail':
            builder = const GameDetailScreen();
            break;
          case '/game_activities_map':
            builder = const GameActivitiesMapScreen();
            break;
          case '/game_play':
            builder = const GamePlayScreen();
            break;
          case '/manage_games':
            builder = const ManageGamesScreen();
            break;
          case '/create_game_unit':
            builder = const CreateGameUnitScreen();
            break;
          case '/activity_completion':
            builder = const ActivityCompletionScreen();
            break;
          case '/unit_completion':
            builder = const UnitCompletionScreen();
            break;
          case '/final_exam':
            builder = const FinalExamScreen();
            break;
          case '/fake_news_detector':
            builder = const FakeNewsDetectorScreen();
            break;
          case '/stereotype_breaker':
            builder = const StereotypeBreakerScreen();
            break;
          case '/word_path':
            builder = const WordPathScreen();
            break;
          case '/game_instructions':
            builder = const GameInstructionsScreen();
            break;
          case '/activity_intro':
            builder = const ActivityIntroScreen();
            break;
          default:
            builder = const WelcomeScreen();
        }
        
        return MaterialPageRoute(
          builder: (context) => builder,
          settings: settings,
        );
      },
    );
  }
}
