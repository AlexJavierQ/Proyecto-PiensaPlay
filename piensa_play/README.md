# PiensaPlay

Una aplicación móvil educativa para niños diseñada para enseñar sobre medios y seguridad digital de manera divertida e interactiva.

## Características

- 🎨 Interfaz colorida y amigable para niños
- 🧸 Sistema de avatares personalizables
- 📱 Diseño responsivo para diferentes dispositivos
- 🔐 Enfoque en seguridad digital educativa

## Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada de la aplicación
├── screens/                  # Pantallas de la aplicación
│   ├── welcome_screen.dart   # Pantalla de bienvenida
│   └── login_screen.dart     # Pantalla de creación de perfil
├── utils/                    # Utilidades y configuraciones
│   └── app_styles.dart       # Estilos globales de la aplicación
└── widgets/                  # Widgets reutilizables (para futuro uso)
```

## Pantallas Implementadas

### 1. Pantalla de Bienvenida (`WelcomeScreen`)
- Presenta la mascota de PiensaPlay
- Botón "Comenzar" para navegar al registro
- Botón "Ver Tutorial" (preparado para implementación futura)
- Selector de idioma (preparado para implementación futura)

### 2. Pantalla de Registro (`LoginScreen`)
- Formulario para nombre y edad del niño
- Selector de avatares con 4 opciones
- Validación de campos requeridos
- Interfaz preparada para integración con Firebase

## Estilos y Diseño

El archivo `app_styles.dart` contiene:
- **Paleta de colores** consistente con el diseño
- **Gradientes** para fondos atractivos
- **Estilos de texto** tipográficos
- **Estilos de botones** reutilizables
- **Decoraciones** para contenedores y elementos UI
- **Espaciado** consistente

### Colores Principales
- Azul Primario: `#1E3A8A`
- Azul Secundario: `#3B82F6`
- Verde Acento: `#10B981`
- Amarillo: `#FBBF24`

## Assets

Los assets están organizados en la carpeta `assets/`:
- `image-removebg-preview 1.png` - Mascota principal
- `Vector.png`, `Vector (2).png`, `Vector (3).png`, `Vector (4).png` - Avatares de usuario
- `image 2.png` - Asset adicional

## Flujo de Navegación Actual

1. **Bienvenida** → Usuario ve la pantalla inicial con la mascota
2. **Comenzar** → Navegación a la pantalla de registro
3. **Registro** → Usuario completa su perfil y selecciona avatar
4. **¡A Jugar!** → Preparado para navegación a la siguiente fase

## Próximos Pasos de Desarrollo

- [ ] Integración con Firebase Authentication
- [ ] Implementación de pantallas de juegos educativos
- [ ] Sistema de progreso y logros
- [ ] Funcionalidad de tutorial interactivo
- [ ] Soporte multiidioma
- [ ] Análisis de uso y métricas educativas

## Comandos de Desarrollo

```bash
# Obtener dependencias
flutter pub get

# Ejecutar la aplicación
flutter run

# Ejecutar tests
flutter test

# Analizar código
flutter analyze
```

## Tecnologías

- **Flutter** - Framework de desarrollo multiplataforma
- **Dart** - Lenguaje de programación
- **Firebase** - Backend as a Service (próxima integración)
- **Material Design** - Sistema de diseño base

---

Desarrollado para enseñar seguridad digital de manera divertida e interactiva para niños.
