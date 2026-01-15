# Widgets Reutilizables - PiensaPlay

Este directorio contiene todos los widgets reutilizables de la aplicación, diseñados para mantener consistencia visual y facilitar el desarrollo.

## 📦 Widgets Disponibles

### 1. **FeedbackPopup** (`feedback_popup.dart`)
Pop-up de feedback inmediato para mostrar si una respuesta es correcta o incorrecta.

```dart
FeedbackPopup.show(
  context: context,
  isCorrect: true,
  customMessage: 'Mensaje opcional',
  onContinue: () {
    // Acción después de cerrar
  },
);
```

### 2. **HintPopup** (`hint_popup.dart`)
Pop-up de pista para ayudar al usuario durante las actividades.

```dart
HintPopup.show(
  context: context,
  hintText: 'Recuerda que los deportes son para todos',
);
```

### 3. **ProgressBarWidget** (`progress_bar_widget.dart`)
Barra de progreso lineal para mostrar avance en actividades.

```dart
ProgressBarWidget(
  current: 3,
  total: 10,
  barColor: Color(0xFFC9E090),
  height: 8,
)
```

### 4. **ScoreCardWidget** (`score_card_widget.dart`)
Tarjeta de puntuación con gradiente naranja/amarillo.

```dart
ScoreCardWidget(
  points: 100,
  label: 'Puntuación',
  showStar: true,
)
```

### 5. **ActivityButton** (`activity_button_widget.dart`)
Botones estándar con estilos consistentes.

```dart
ActivityButton(
  text: 'Continuar',
  type: ActivityButtonType.primary,
  icon: Icons.arrow_forward,
  onPressed: () {},
)
```

### 6. **ScenarioCardWidget** (`scenario_card_widget.dart`)
Tarjeta de escenario para actividades de estereotipos.

```dart
ScenarioCardWidget(
  title: 'Niña jugando con muñecas',
  subtitle: 'Solo las niñas pueden jugar',
  icon: Icons.toys,
  state: ScenarioState.incorrect,
  onTap: () {},
)
```

### 7. **LearningPointsWidget** (`learning_points_widget.dart`)
Widget para mostrar puntos de aprendizaje después de completar una actividad.

```dart
LearningPointsWidget(
  title: '¿Qué Aprendiste?',
  learningPoints: [
    'Siempre verifica la fuente',
    'Desconfía de mensajes emocionales',
  ],
)
```

### 8. **AchievementBadge** (`achievement_badge.dart`) ⭐ NUEVO
Widget de logros/badges para gamificación.

```dart
AchievementBadge(
  title: 'Explorador',
  description: 'Completa 5 actividades',
  icon: Icons.explore,
  color: Color(0xFF2196F3),
  isUnlocked: true,
  progress: 3,
  total: 5,
)
```

También incluye:
- `AchievementsGrid`: Grid responsive de logros
- `PiensaPlayAchievements`: Lista de logros predefinidos
- `AchievementUnlockedPopup`: Popup de celebración

---

## 🎮 Nuevos Tipos de Juegos

### Pantallas de Juego Implementadas

| Tipo | Archivo | Descripción |
|------|---------|-------------|
| **Quiz** | `quiz_game_screen.dart` | Preguntas de opción múltiple |
| **Emparejar** | `match_pairs_screen.dart` | Conectar conceptos con definiciones |
| **Memorama** | `memory_game_screen.dart` | Encontrar parejas de cartas |
| **Ordenar** | `order_sequence_screen.dart` | Ordenar pasos arrastrando |
| **Completar** | `fill_blanks_screen.dart` | Llenar espacios en blanco |
| **Fake News** | `fake_news_detector_screen.dart` | Detectar noticias falsas |
| **Estereotipos** | `stereotype_breaker_screen.dart` | Romper estereotipos |
| **Palabras** | `word_path_screen.dart` | Clasificar palabras |

---

## 🎨 Importación

Para usar todos los widgets, importa el archivo índice:

```dart
import 'package:piensa_play/widgets/widgets.dart';
```

---

## 🎯 Convenciones de Diseño

**Colores principales:**
- Azul primario: `#132757`
- Verde éxito: `#C9E090`
- Rojo error: `#FF8FA3`
- Amarillo acento: `#F6E16B`

**Estilos:**
- Bordes redondeados: 12-24px
- Sombras sutiles: `blurRadius: 8-10`, `offset: (0, 4)`
- Padding estándar: 16-24px
- Fuentes: Peso 700 títulos, 600 subtítulos

---

## ✅ Estado de Implementación

### Widgets Core
- [x] FeedbackPopup
- [x] HintPopup
- [x] ProgressBarWidget
- [x] ScoreCardWidget
- [x] ActivityButton
- [x] ScenarioCardWidget
- [x] LearningPointsWidget
- [x] AchievementBadge

### Tipos de Juego
- [x] Quiz Interactivo
- [x] Emparejar Conceptos
- [x] Memorama
- [x] Ordenar Secuencia
- [x] Completar Oraciones
- [x] Fake News Detector
- [x] Stereotype Breaker
- [x] Word Path

**Última actualización:** Enero 2026
