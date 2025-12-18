# Widgets Reutilizables - PiensaPlay

Este directorio contiene todos los widgets reutilizables de la aplicación, diseñados para mantener consistencia visual y facilitar el desarrollo.

## 📦 Widgets Disponibles

### 1. **FeedbackPopup** (`feedback_popup.dart`)
Pop-up de feedback inmediato para mostrar si una respuesta es correcta o incorrecta.

**Uso:**
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

**Características:**
- Ícono circular verde (correcto) o rojo (incorrecto)
- Mensaje personalizable
- Botón amarillo "Continuar"
- No se puede cerrar tocando fuera (barrierDismissible: false)

---

### 2. **HintPopup** (`hint_popup.dart`)
Pop-up de pista para ayudar al usuario durante las actividades.

**Uso:**
```dart
HintPopup.show(
  context: context,
  hintText: 'Recuerda que los deportes son para todos',
);
```

**Características:**
- Ícono de bombilla verde
- Título "¡Pista!"
- Se puede cerrar tocando fuera

---

### 3. **ProgressBarWidget** (`progress_bar_widget.dart`)
Barra de progreso lineal para mostrar avance en actividades.

**Uso:**
```dart
ProgressBarWidget(
  current: 3,
  total: 10,
  barColor: Color(0xFFC9E090),
  height: 8,
)
```

**También incluye:**
- `CircularProgressWidget`: Progreso circular con porcentaje

---

### 4. **ScoreCardWidget** (`score_card_widget.dart`)
Tarjeta de puntuación con gradiente naranja/amarillo.

**Uso:**
```dart
ScoreCardWidget(
  points: 100,
  label: 'Puntuación',
  showStar: true,
)
```

**También incluye:**
- `MissionSummaryWidget`: Resumen completo con correctas, incorrectas y puntuación final

---

### 5. **ActivityButton** (`activity_button_widget.dart`)
Botones estándar con estilos consistentes.

**Uso:**
```dart
ActivityButton(
  text: 'Continuar',
  type: ActivityButtonType.primary,
  icon: Icons.arrow_forward,
  onPressed: () {},
)
```

**Tipos disponibles:**
- `primary`: Azul (acción principal)
- `secondary`: Amarillo (acción secundaria)
- `success`: Verde (éxito)
- `danger`: Rojo (peligro)
- `outline`: Blanco con borde azul

**También incluye:**
- `AnswerButton`: Botones de respuesta Verdadero/Falso

---

### 6. **ScenarioCardWidget** (`scenario_card_widget.dart`)
Tarjeta de escenario para actividades de estereotipos.

**Uso:**
```dart
ScenarioCardWidget(
  title: 'Niña jugando con muñecas',
  subtitle: 'Solo las niñas pueden jugar con muñecas',
  icon: Icons.toys,
  state: ScenarioState.incorrect,
  onTap: () {},
)
```

**Estados disponibles:**
- `neutral`: Sin estado
- `selected`: Seleccionado por el usuario
- `correct`: Respuesta correcta
- `incorrect`: Respuesta incorrecta (estereotipo)

---

### 7. **LearningPointsWidget** (`learning_points_widget.dart`)
Widget para mostrar puntos de aprendizaje después de completar una actividad.

**Uso:**
```dart
LearningPointsWidget(
  title: '¿Qué Aprendiste?',
  learningPoints: [
    'Siempre verifica la fuente de la información',
    'Desconfía de mensajes con lenguaje muy emocional',
  ],
)
```

**También incluye:**
- `ClueListWidget`: Lista de pistas a detectar en actividades de fake news

---

## 🎨 Importación

Para usar todos los widgets, importa el archivo índice:

```dart
import 'package:piensa_play/widgets/widgets.dart';
```

O importa widgets individuales:

```dart
import 'package:piensa_play/widgets/feedback_popup.dart';
```

---

## 🎯 Convenciones de Diseño

Todos los widgets siguen estas convenciones:

- **Colores principales:**
  - Azul primario: `AppStyles.primaryBlue` (#132757)
  - Verde éxito: `#C9E090`
  - Rojo error: `#FF8FA3`
  - Amarillo acento: `#F6E16B`

- **Bordes redondeados:** 12-24px según el tamaño
- **Sombras sutiles:** `blurRadius: 8-10`, `offset: (0, 4)`
- **Padding estándar:** 16-24px
- **Fuentes:** Peso 700 para títulos, 600 para subtítulos

---

## 📝 Notas para Desarrolladores

1. **No modificar estilos directamente:** Usa `AppStyles` para mantener consistencia
2. **Reutilizar antes de crear:** Verifica si existe un widget similar antes de crear uno nuevo
3. **Documentar cambios:** Actualiza este README al agregar nuevos widgets
4. **Mantener accesibilidad:** Asegura que los widgets sean accesibles para todos los usuarios

---

## ✅ Estado de Implementación

- [x] FeedbackPopup
- [x] HintPopup
- [x] ProgressBarWidget
- [x] ScoreCardWidget
- [x] ActivityButton
- [x] ScenarioCardWidget
- [x] LearningPointsWidget

**Última actualización:** Diciembre 2024
