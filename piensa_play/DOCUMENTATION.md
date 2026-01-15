# 🎮 PiensaPlay - Documentación Técnica

## 📋 Descripción General

**PiensaPlay** es una aplicación educativa gamificada diseñada para enseñar pensamiento crítico y alfabetización digital a niños y adolescentes. La app utiliza minijuegos interactivos para enseñar a identificar fake news, estereotipos, ciberbullying y otros conceptos relacionados con la ciudadanía digital.

## 🛠️ Stack Tecnológico

| Tecnología | Versión | Uso |
|------------|---------|-----|
| Flutter | 3.x | Framework UI multiplataforma |
| Dart | 3.x | Lenguaje de programación |
| Firebase Firestore | Latest | Base de datos NoSQL en tiempo real |
| Firebase Core | Latest | Autenticación y servicios |

## 📁 Estructura del Proyecto

```
lib/
├── main.dart                    # Punto de entrada, rutas y configuración
├── firebase_options.dart        # Configuración de Firebase
├── screens/                     # Todas las pantallas (37 archivos)
├── widgets/                     # Componentes reutilizables (13 archivos)
└── utils/                       # Utilidades y servicios (5 archivos)
```

---

## 🎯 Flujos de Usuario

### 👦 Flujo del Estudiante

```
WelcomeScreen → LoginScreen → HomeScreen
                                    ├── GameUnitsScreen → GameActivitiesMapScreen → [Minijuegos]
                                    ├── GlossaryScreen
                                    ├── ProgressScreen
                                    ├── RewardsShopScreen
                                    ├── StudentClassesScreen → JoinClassScreen
                                    └── SettingsScreen
```

### 👨‍🏫 Flujo del Profesor/Tutor

```
WelcomeScreen → TutorLoginScreen → TutorDashboardScreen
                                        ├── CreateClassScreen
                                        ├── ClassDetailScreen (Unidades, Estudiantes, Ajustes)
                                        ├── CreateGameUnitScreen
                                        └── ManageGlossaryScreen
```

---

## 📱 Pantallas (Screens)

### Pantallas Principales

| Archivo | Descripción |
|---------|-------------|
| `welcome_screen.dart` | Pantalla de bienvenida con animaciones |
| `login_screen.dart` | Creación de perfil de estudiante (nombre, edad, avatar) |
| `home_screen.dart` | Dashboard principal del estudiante con menú de opciones |
| `settings_screen.dart` | Configuración y perfil del usuario |

### Sistema de Clases (NUEVO)

| Archivo | Descripción |
|---------|-------------|
| `create_class_screen.dart` | Crear clase con código único de 6 caracteres |
| `join_class_screen.dart` | Unirse a clase con código |
| `class_detail_screen.dart` | Detalle de clase (tabs: Unidades, Estudiantes, Ajustes) |
| `student_classes_screen.dart` | Lista de clases del estudiante |
| `tutor_dashboard_screen.dart` | Panel de control del profesor con estadísticas |
| `tutor_login_screen.dart` | Login del profesor (user: tutor, pass: 1234) |

### Sistema de Juegos

| Archivo | Descripción |
|---------|-------------|
| `game_units_screen.dart` | Lista de unidades de juego disponibles |
| `game_activities_map_screen.dart` | Mapa de actividades dentro de una unidad |
| `activity_intro_screen.dart` | Introducción a la actividad |
| `game_instructions_screen.dart` | Instrucciones del juego |
| `game_play_screen.dart` | Pantalla de juego genérica |

### Tipos de Minijuegos

| Archivo | Tipo | Descripción |
|---------|------|-------------|
| `quiz_game_screen.dart` | Quiz | Preguntas de opción múltiple |
| `match_pairs_screen.dart` | Emparejar | Conectar conceptos relacionados |
| `memory_game_screen.dart` | Memoria | Encontrar parejas de cartas |
| `order_sequence_screen.dart` | Ordenar | Ordenar secuencias lógicas |
| `fill_blanks_screen.dart` | Completar | Rellenar espacios en blanco |
| `fake_news_detector_screen.dart` | Fake News | Identificar noticias falsas |
| `stereotype_breaker_screen.dart` | Estereotipos | Identificar estereotipos |
| `word_path_screen.dart` | Palabras | Clasificar palabras positivas/negativas |

### Pantallas de Progreso

| Archivo | Descripción |
|---------|-------------|
| `progress_screen.dart` | Ver progreso y logros |
| `activity_completion_screen.dart` | Celebración al completar actividad |
| `unit_completion_screen.dart` | Celebración al completar unidad |
| `celebration_screen.dart` | Animación de celebración con confeti |
| `final_exam_screen.dart` | Examen final de unidad |

### Tienda y Recompensas

| Archivo | Descripción |
|---------|-------------|
| `rewards_shop_screen.dart` | Tienda con avatares, marcos y temas |
| `glossary_screen.dart` | Glosario de términos aprendidos |

### Gestión (Tutor)

| Archivo | Descripción |
|---------|-------------|
| `manage_glossary_screen.dart` | Administrar términos del glosario |
| `add_glossary_term_screen.dart` | Agregar nuevo término |
| `manage_games_screen.dart` | Administrar juegos |
| `create_game_unit_screen.dart` | Crear nueva unidad de juego |
| `game_form_dialog.dart` | Formulario para crear actividades |

---

## 🧩 Widgets Reutilizables

| Archivo | Descripción |
|---------|-------------|
| `custom_bottom_nav.dart` | Barra de navegación inferior |
| `piensa_app_bar.dart` | AppBar personalizado |
| `achievement_badge.dart` | Insignias de logros |
| `feedback_popup.dart` | Popups de retroalimentación |
| `hint_popup.dart` | Popups de pistas |
| `progress_bar_widget.dart` | Barra de progreso animada |
| `score_card_widget.dart` | Tarjeta de puntuación |
| `learning_points_widget.dart` | Widget de puntos de aprendizaje |
| `activity_button_widget.dart` | Botones de actividad |
| `scenario_card_widget.dart` | Tarjetas de escenarios |
| `piensa_error_widget.dart` | Widget de errores |

---

## 🔧 Utilidades (Utils)

### `app_styles.dart`
Sistema de diseño centralizado con:
- **Colores**: primaryBlue, accentGreen, yellow, coral, etc.
- **Tipografía**: Estilos de texto predefinidos
- **Decoraciones**: BorderRadius, shadows, gradients
- **Constantes**: Tamaños, espaciados

### `firebase_service.dart`
Servicio de acceso a datos con métodos para:
- **Usuarios**: createUser, getUserByTag, getUserStream
- **Tutores**: validateTutor
- **Clases**: createClass, joinClass, getTutorClasses, getStudentClasses
- **Unidades**: getGameUnits, getClassUnits
- **Actividades**: getActivities, updateActivityStatus
- **Glosario**: getGlossaryTerms, addGlossaryTerm
- **Recompensas**: purchaseItem, equipItem
- **Demo**: initializeDemoData

### `local_storage_service.dart`
Almacenamiento local para:
- Sesión del usuario
- Preferencias

### `page_transitions.dart` & `custom_page_route.dart`
Transiciones animadas personalizadas:
- Fade
- Slide (izquierda, derecha, arriba, abajo)
- Scale
- Slide + Fade

---

## 🔥 Estructura de Firebase Firestore

### Colecciones

```
📁 users/
    ├── name: string
    ├── tag: string (6 dígitos únicos)
    ├── age: number
    ├── avatarIndex: number
    ├── totalXp: number
    ├── walletBalance: number
    ├── purchasedItems: array
    ├── equipped_avatar: string
    ├── equipped_frame: string
    └── equipped_theme: string

📁 tutors/
    ├── username: string
    ├── password: string
    ├── name: string
    └── createdAt: timestamp

📁 classes/
    ├── name: string
    ├── description: string
    ├── code: string (6 caracteres únicos)
    ├── tutorId: string
    ├── studentCount: number
    └── createdAt: timestamp

📁 class_members/
    ├── classId: string
    ├── userId: string
    ├── name: string
    ├── tag: string
    ├── xp: number
    └── joinedAt: timestamp

📁 game_units/
    ├── title: string
    ├── subtitle: string
    ├── description: string
    ├── status: string (locked, in_progress, completed)
    ├── progress: number
    ├── order: number
    ├── color: number (hex)
    ├── icon: string
    └── classId: string (opcional)
    
    📁 activities/ (subcolección)
        ├── title: string
        ├── subtitle: string
        ├── type: string (quiz, memory, match_pairs, etc.)
        ├── order: number
        ├── color: number
        ├── icon: string
        └── content: map (específico del tipo)

📁 glossary_terms/
    ├── term: string
    ├── definition: string
    └── category: string
```

---

## 🎨 Sistema de Diseño

### Paleta de Colores Principal

```dart
primaryBlue: Color(0xFF132757)    // Azul oscuro principal
mediumBlue: Color(0xFF1E4B8E)     // Azul medio
lightBlue: Color(0xFF42A5F5)      // Azul claro
accentGreen: Color(0xFF4CAF50)    // Verde de acción/éxito
limeGreen: Color(0xFFBDD87B)      // Verde lima
yellow: Color(0xFFFBBF24)         // Amarillo dorado
coral: Color(0xFFFF6B6B)          // Coral/rojo para errores
backgroundLight: Color(0xFFF0F7FF) // Fondo claro
```

### Rarezas de Items (Tienda)

| Rareza | Color | Precio Base |
|--------|-------|-------------|
| LEGENDARIO | Amarillo dorado | 500+ |
| ÉPICO | Púrpura | 300-400 |
| RARO | Azul | 150-250 |
| COMÚN | Gris | 50-100 |

---

## 🚀 Comandos de Desarrollo

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en Chrome (desarrollo)
flutter run -d chrome --web-port=8080

# Ejecutar en Android
flutter run -d <device_id>

# Hot reload
r (en terminal)

# Hot restart
R (en terminal)

# Build para producción
flutter build web
flutter build apk
```

---

## 🔐 Credenciales de Prueba

### Tutor/Profesor
- **Usuario**: tutor
- **Contraseña**: 1234 o 123456

### Estudiante
- Crear nuevo perfil con nombre, edad y avatar
- Se genera automáticamente un tag de 6 dígitos

---

## 📝 Notas Importantes

1. **Firebase Indexes**: Las consultas con `where` + `orderBy` requieren índices compuestos. Se han removido los `orderBy` para evitar esto.

2. **Datos Demo**: Al iniciar la app, se crean datos de demostración automáticamente si no existen.

3. **Navegación**: Toda la navegación usa `Navigator.pushNamed` con argumentos para pasar datos entre pantallas.

4. **Estado**: Actualmente no hay gestión de estado global (Provider/Riverpod). Los datos se pasan mediante argumentos de navegación.

5. **Animaciones**: Se usan AnimationController y transiciones personalizadas para una experiencia fluida.

---

## 🐛 Problemas Conocidos

1. Las clases creadas pueden no aparecer inmediatamente si Firebase no tiene los índices configurados.
2. El splash screen se deshabilitó porque causaba problemas en algunos dispositivos.

---

## 👥 Equipo

Desarrollado para el curso de Desarrollo Móvil.

**Última actualización**: Enero 2026
