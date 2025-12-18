# PiensaPlay 🚀

Una plataforma educativa gamificada diseñada para que niños y niñas aprendan sobre **alfabetización mediática** y **seguridad digital** de manera divertida, segura e interactiva.

## 🌟 Características Principales

- **Aprendizaje Basado en Juegos:** Misiones interactivas sobre Fake News, Estereotipos y Ciberbullying.
- **Ruta de Aprendizaje:** Mapa de actividades con progresión lógica (Intro -> Instrucciones -> Juego -> Examen).
- **Perfiles Personalizados:** Selección de avatares y etiquetas únicas (#TAG) para cada pequeño aventurero.
- **Panel del Tutor:** Herramientas para que profesores y padres gestionen el contenido y el glosario.
- **Backend Robusto:** Sincronización en tiempo real con Firebase Firestore.
- **Diseño Kids-First:** Interfaz vibrante, centrada y optimizada para la facilidad de uso infantil.

## 🛠️ Estructura del Proyecto

```text
lib/
├── main.dart                 # Configuración de rutas y Firebase
├── screens/                  # +25 Pantallas organizadas por flujo
│   ├── welcome/login         # Onboarding del usuario
│   ├── home_screen.dart      # Dashboard principal (Aventura)
│   ├── game_units/           # Mapa de misiones y unidades
│   ├── games/                # Lógica de minijuegos (Fake News, Word Path, etc.)
│   └── tutor/                # Gestión administrativa
├── utils/                    # Servicios (Firebase, LocalStorage) y Estilos
└── widgets/                  # Componentes UI reutilizables y popups de feedback
```

## 🚀 Flujo de la Aplicación

1.  **Onboarding:** El niño crea su perfil con un avatar y recibe un TAG único.
2.  **Dashboard:** Un centro de mando que motiva al niño a continuar su última misión.
3.  **Mapa de Misiones:** Visualización del progreso a través de diferentes desafíos temáticos.
4.  **Minijuegos:** Actividades prácticas donde se aplican los conceptos aprendidos.
5.  **Glosario:** Un diccionario interactivo para reforzar el vocabulario digital.

## 🎨 Identidad Visual

- **Colores:** Azul Profundo (`#132757`), Amarillo Sol (`#F6E16B`), Verde Aventura (`#BDD87B`).
- **Tipografía:** Arial / Rounded para máxima legibilidad.
- **Mascota:** Un compañero guía que aparece en momentos clave para dar instrucciones.

## 🛠️ Tecnologías

- **Flutter & Dart** (SDK ^3.9.2)
- **Firebase Core & Cloud Firestore** (Persistencia de datos)
- **Shared Preferences** (Persistencia local de sesión)

## 🏗️ Cómo Empezar

1.  Asegúrate de tener Flutter instalado.
2.  Clona el repositorio.
3.  Ejecuta `flutter pub get`.
4.  **Importante:** Reinicia la app por completo tras la primera compilación para cargar los plugins nativos.

---
*Desarrollado para empoderar a la próxima generación de ciudadanos digitales.*
