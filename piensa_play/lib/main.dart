import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'utils/app_styles.dart';
import 'utils/firebase_service.dart';
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
import 'screens/quiz_game_screen.dart';
import 'screens/match_pairs_screen.dart';
import 'screens/memory_game_screen.dart';
import 'screens/order_sequence_screen.dart';
import 'screens/fill_blanks_screen.dart';
import 'screens/rewards_shop_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/celebration_screen.dart';
import 'screens/create_class_screen.dart';
import 'screens/join_class_screen.dart';
import 'screens/class_detail_screen.dart';
import 'screens/student_classes_screen.dart';
import 'utils/custom_page_route.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PiensaPlayApp());
}

class PiensaPlayApp extends StatefulWidget {
  const PiensaPlayApp({super.key});

  @override
  State<PiensaPlayApp> createState() => _PiensaPlayAppState();
}

class _PiensaPlayAppState extends State<PiensaPlayApp> {
  late Future<void> _initializationFuture;

  @override
  void initState() {
    super.initState();
    _initializationFuture = _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    // Initialize demo data if needed
    await FirebaseService.initializeDemoData();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PiensaPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppStyles.primaryBlue,
          primary: AppStyles.primaryBlue,
          secondary: AppStyles.accentGreen,
        ),
        fontFamily: 'Arial',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: AppStyles.backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppStyles.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: FutureBuilder(
        future: _initializationFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error al conectar con la base de datos:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.done) {
            return const WelcomeScreen();
          }

          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        },
      ),
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
          case '/quiz_game':
            builder = const QuizGameScreen();
            break;
          case '/match_pairs':
            builder = const MatchPairsScreen();
            break;
          case '/memory_game':
            builder = const MemoryGameScreen();
            break;
          case '/order_sequence':
            builder = const OrderSequenceScreen();
            break;
          case '/fill_blanks':
            builder = const FillBlanksScreen();
            break;
          case '/rewards_shop':
            builder = RewardsShopScreen(
              userId: args['userId'] ?? (args['user'] as Map<String, dynamic>?)?['id'] ?? 'temp',
            );
            break;
          case '/splash':
            builder = const SplashScreen();
            break;
          case '/celebration':
            builder = const CelebrationScreen();
            break;
          case '/create_class':
            builder = CreateClassScreen(
              tutorId: args['tutorId'] ?? 'demo_tutor',
            );
            break;
          case '/join_class':
            builder = JoinClassScreen(
              userId: args['userId'] ?? 'temp',
              userName: args['userName'] ?? 'Usuario',
            );
            break;
          case '/class_detail':
            builder = ClassDetailScreen(
              classId: args['classId'] ?? '',
              classData: args['classData'] ?? {},
              isTutor: args['isTutor'] ?? false,
            );
            break;
          case '/student_classes':
            builder = StudentClassesScreen(
              userId: args['userId'] ?? 'temp',
              userName: args['userName'] ?? 'Usuario',
            );
            break;
          default:
            builder = const WelcomeScreen();
        }
        
        // Usar transiciones personalizadas
        return createRoute(
          builder,
          type: _getTransitionType(settings.name),
          settings: settings,
        );
      },
    );
  }

  RouteTransitionType _getTransitionType(String? routeName) {
    switch (routeName) {
      case '/celebration':
        return RouteTransitionType.scale;
      case '/splash':
        return RouteTransitionType.fade;
      case '/home':
      case '/glossary':
      case '/progress':
      case '/settings':
        return RouteTransitionType.fadeScale;
      case '/rewards_shop':
      case '/tutor_dashboard':
        return RouteTransitionType.slideUp;
      default:
        return RouteTransitionType.slideAndFade;
    }
  }
}
