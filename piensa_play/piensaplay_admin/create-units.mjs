// Script para crear las 3 unidades principales con contenido educativo completo
// Ejecutar con: node create-units.mjs

import { initializeApp } from 'firebase/app';
import { getFirestore, doc, setDoc, deleteDoc, getDocs, collection } from 'firebase/firestore';

const firebaseConfig = {
    apiKey: "AIzaSyCsTvJhGDO4M1F8ulxH3PDFr-8_dgtVqhE",
    authDomain: "piensa-play-56a1c.firebaseapp.com",
    projectId: "piensa-play-56a1c",
    storageBucket: "piensa-play-56a1c.appspot.com",
    messagingSenderId: "738250464476",
    appId: "1:738250464476:web:a2e8bc0b5a1e8c5e8f1234"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ============================================
// UNIDAD 1: FAKE NEWS
// Aprender a identificar noticias falsas
// ============================================
const unitFakeNews = {
    id: 'unit_fake_news',
    title: '¡Alerta Fake News!',
    subtitle: 'Detecta la información falsa',
    description: 'Aprende a identificar noticias falsas, verificar fuentes y no caer en la desinformación. ¡Conviértete en un detective digital!',
    icon: 'newspaper',
    color: '#EF4444', // Rojo
    order: 1,
    isActive: true,
    totalXp: 300,
    estimatedTime: '15 min',
    classId: null, // Required for global units
    games: [
        {
            id: 'fake_news_quiz_1',
            title: '¿Real o Falso?',
            subtitle: 'Nivel 1 - Titulares',
            type: 'quiz',
            icon: 'help_circle',
            color: 0xFFDC2626,
            order: 1,
            xpReward: 50,
            questions: [
                {
                    question: 'Una noticia dice: "URGENTE: Científicos confirman que dormir 2 horas es suficiente para estar saludable" ¿Qué señal de alerta ves?',
                    hint: 'Fíjate en las palabras exageradas',
                    explanation: 'La palabra "URGENTE" en mayúsculas y una afirmación médica extrema sin citar fuentes son señales de fake news.',
                    answers: [
                        { text: 'Usa mayúsculas y hace afirmaciones extremas', isCorrect: true },
                        { text: 'No tiene ninguna señal de alerta', isCorrect: false },
                        { text: 'Es información científica confiable', isCorrect: false },
                        { text: 'Todas las noticias urgentes son verdaderas', isCorrect: false }
                    ]
                },
                {
                    question: '¿Cuál de estas fuentes es más confiable para verificar una noticia de salud?',
                    explanation: 'Las organizaciones oficiales como la OMS tienen procesos de verificación científica antes de publicar información.',
                    answers: [
                        { text: 'Un video viral en TikTok', isCorrect: false },
                        { text: 'Un mensaje de WhatsApp de tu tía', isCorrect: false },
                        { text: 'La página oficial de la OMS', isCorrect: true },
                        { text: 'Un blog llamado "verdades_ocultas.com"', isCorrect: false }
                    ]
                },
                {
                    question: '¿Qué es lo PRIMERO que debes hacer antes de compartir una noticia impactante?',
                    hint: 'Piensa antes de actuar',
                    explanation: 'Siempre debemos verificar la información antes de compartirla para no contribuir a la desinformación.',
                    answers: [
                        { text: 'Compartirla inmediatamente con todos', isCorrect: false },
                        { text: 'Verificar si es real en otras fuentes', isCorrect: true },
                        { text: 'Agregar un comentario y reenviarlo', isCorrect: false },
                        { text: 'Guardarla para leerla después', isCorrect: false }
                    ]
                },
                {
                    question: 'Una imagen muestra a un político haciendo algo malo, pero no hay ninguna noticia al respecto. ¿Qué podría ser?',
                    explanation: 'Las imágenes pueden ser manipuladas fácilmente. Si no hay confirmación de medios serios, probablemente sea falsa.',
                    answers: [
                        { text: 'Una foto manipulada o sacada de contexto', isCorrect: true },
                        { text: 'Una primicia exclusiva', isCorrect: false },
                        { text: 'Información 100% verdadera', isCorrect: false },
                        { text: 'Una conspiración de los medios', isCorrect: false }
                    ]
                },
                {
                    question: '¿Por qué la gente crea fake news?',
                    explanation: 'Las fake news buscan generar dinero con clics, manipular opiniones o simplemente causar caos.',
                    answers: [
                        { text: 'Para informar mejor a la gente', isCorrect: false },
                        { text: 'Para ganar dinero, influir o causar daño', isCorrect: true },
                        { text: 'Porque no saben escribir bien', isCorrect: false },
                        { text: 'Por accidente siempre', isCorrect: false }
                    ]
                }
            ]
        },
        {
            id: 'fake_news_memory',
            title: 'Memoria de Verificación',
            subtitle: 'Conecta conceptos clave',
            type: 'memory',
            icon: 'brain',
            color: 0xFFF87171,
            order: 2,
            xpReward: 50,
            cards: [
                { content: '🔍', pair: 'Verificar' },
                { content: '📰', pair: 'Noticia' },
                { content: '❌', pair: 'Fake News' },
                { content: '✅', pair: 'Fuente confiable' },
                { content: '⚠️', pair: 'Señal de alerta' },
                { content: '🌐', pair: 'Internet' }
            ]
        },
        {
            id: 'fake_news_quiz_2',
            title: 'Señales de Alerta',
            subtitle: 'Nivel 2 - Avanzado',
            type: 'quiz',
            icon: 'alert_triangle',
            color: 0xFFB91C1C,
            order: 3,
            xpReward: 75,
            questions: [
                {
                    question: '¿Cuál de estas NO es una señal de una noticia falsa?',
                    explanation: 'Las noticias reales citan fuentes verificables, mientras que las falsas suelen tener errores y exageraciones.',
                    answers: [
                        { text: 'Muchos errores de ortografía', isCorrect: false },
                        { text: 'No menciona el autor', isCorrect: false },
                        { text: 'Cita fuentes oficiales y verificables', isCorrect: true },
                        { text: 'Promete curas milagrosas', isCorrect: false }
                    ]
                },
                {
                    question: 'Tu amigo te envía una cadena de WhatsApp sobre un premio por reenviarla. ¿Qué haces?',
                    hint: 'Si suena demasiado bueno para ser verdad...',
                    explanation: 'Las cadenas de mensajes prometiendo premios son siempre falsas y pueden ser intentos de estafa.',
                    answers: [
                        { text: 'La reenvío a 10 personas para ganar', isCorrect: false },
                        { text: 'Ignoro el mensaje porque es una estafa', isCorrect: true },
                        { text: 'La publico en mis redes sociales', isCorrect: false },
                        { text: 'Doy mis datos personales para el premio', isCorrect: false }
                    ]
                },
                {
                    question: '¿Qué significa "clickbait"?',
                    explanation: 'El clickbait usa títulos exagerados para que hagas clic y generar dinero con publicidad.',
                    answers: [
                        { text: 'Una noticia verificada', isCorrect: false },
                        { text: 'Títulos exagerados para atraer clics', isCorrect: true },
                        { text: 'Un tipo de virus informático', isCorrect: false },
                        { text: 'Una red social nueva', isCorrect: false }
                    ]
                },
                {
                    question: 'Ves una noticia sobre un famoso que murió. ¿Cómo verificas si es real?',
                    explanation: 'Los medios reconocidos confirman las noticias importantes antes de publicarlas.',
                    answers: [
                        { text: 'Si tiene muchos likes, es verdad', isCorrect: false },
                        { text: 'Busco en medios reconocidos como CNN, BBC, etc.', isCorrect: true },
                        { text: 'Si lo dice mi amigo, es suficiente', isCorrect: false },
                        { text: 'Las redes sociales nunca mienten', isCorrect: false }
                    ]
                },
                {
                    question: '¿Por qué es importante no compartir fake news?',
                    explanation: 'La desinformación puede causar daños reales como pánico, discriminación y malas decisiones de salud.',
                    answers: [
                        { text: 'Porque podemos dañar a otras personas', isCorrect: true },
                        { text: 'No es importante, es solo información', isCorrect: false },
                        { text: 'Solo importa si la noticia es sobre mí', isCorrect: false },
                        { text: 'Las fake news no afectan a nadie', isCorrect: false }
                    ]
                }
            ]
        },
        {
            id: 'fake_news_quiz_3',
            title: 'Experto Anti-Fake',
            subtitle: 'Desafío Final',
            type: 'quiz',
            icon: 'award',
            color: 0xFF991B1B,
            order: 4,
            xpReward: 125,
            questions: [
                {
                    question: 'Una página web tiene el dominio "bbc-noticias-reales.blogspot.com". ¿Qué opinas?',
                    explanation: 'Los sitios falsos imitan nombres de medios reales. BBC solo usa bbc.com o bbc.co.uk oficialmente.',
                    answers: [
                        { text: 'Es la BBC porque tiene BBC en el nombre', isCorrect: false },
                        { text: 'Es falsa porque imita un nombre real en un blog', isCorrect: true },
                        { text: 'Todos los blogs son confiables', isCorrect: false },
                        { text: 'El dominio no importa', isCorrect: false }
                    ]
                },
                {
                    question: '¿Qué es una "cámara de eco" en redes sociales?',
                    hint: 'Tiene que ver con ver siempre las mismas opiniones',
                    explanation: 'Las redes nos muestran contenido similar al que ya vemos, creando burbujas donde solo escuchamos opiniones parecidas.',
                    answers: [
                        { text: 'Un filtro de sonido para videos', isCorrect: false },
                        { text: 'Ver solo información que confirma lo que ya creemos', isCorrect: true },
                        { text: 'Una función para grabar audio', isCorrect: false },
                        { text: 'Un tipo de micrófono especial', isCorrect: false }
                    ]
                },
                {
                    question: 'Para verificar una foto, ¿qué herramienta puedes usar?',
                    explanation: 'Google Imágenes permite buscar una foto y ver dónde más aparece, ayudando a detectar fotos falsas o sacadas de contexto.',
                    answers: [
                        { text: 'Búsqueda inversa de Google Imágenes', isCorrect: true },
                        { text: 'Zoom de la foto', isCorrect: false },
                        { text: 'Filtros de Instagram', isCorrect: false },
                        { text: 'Recortar la imagen', isCorrect: false }
                    ]
                }
            ]
        }
    ]
};

// ============================================
// UNIDAD 2: VERACIDAD
// Verificar información y fuentes confiables
// ============================================
const unitVeracidad = {
    id: 'unit_veracidad',
    title: 'Detectives de la Verdad',
    subtitle: 'Verifica antes de creer',
    description: 'Desarrolla habilidades para verificar información, identificar fuentes confiables y convertirte en un ciudadano digital responsable.',
    icon: 'search',
    color: '#3B82F6', // Azul
    order: 2,
    isActive: true,
    totalXp: 350,
    estimatedTime: '20 min',
    classId: null, // Required for global units
    games: [
        {
            id: 'veracidad_quiz_1',
            title: 'Fuentes Confiables',
            subtitle: 'Aprende a evaluar',
            type: 'quiz',
            icon: 'check_circle',
            color: 0xFF2563EB,
            order: 1,
            xpReward: 50,
            questions: [
                {
                    question: '¿Qué tipo de fuente es más confiable para una tarea escolar sobre animales?',
                    explanation: 'National Geographic es una organización reconocida con expertos que verifican la información.',
                    answers: [
                        { text: 'Wikipedia (sin verificar)', isCorrect: false },
                        { text: 'National Geographic', isCorrect: true },
                        { text: 'Yahoo Respuestas', isCorrect: false },
                        { text: 'Un foro de internet', isCorrect: false }
                    ]
                },
                {
                    question: '¿Qué característica tiene una fuente confiable?',
                    hint: 'Piensa en quién escribe la información',
                    explanation: 'Las fuentes confiables identifican claramente quién escribe y de dónde viene la información.',
                    answers: [
                        { text: 'Tiene autor identificado y fecha', isCorrect: true },
                        { text: 'Tiene muchos anuncios publicitarios', isCorrect: false },
                        { text: 'Está escrita en mayúsculas', isCorrect: false },
                        { text: 'Tiene colores brillantes', isCorrect: false }
                    ]
                },
                {
                    question: '¿Qué significa verificar información?',
                    explanation: 'Verificar es comprobar si algo es verdad buscando la misma información en varias fuentes confiables.',
                    answers: [
                        { text: 'Copiar y pegar en otro lugar', isCorrect: false },
                        { text: 'Compartirla con amigos', isCorrect: false },
                        { text: 'Comprobar si es cierta en múltiples fuentes', isCorrect: true },
                        { text: 'Leer solo el título', isCorrect: false }
                    ]
                },
                {
                    question: '¿Cuál de estas opciones indica que un sitio web es profesional?',
                    explanation: 'Los sitios profesionales tienen diseño limpio, información de contacto y política de privacidad.',
                    answers: [
                        { text: 'Muchas ventanas emergentes', isCorrect: false },
                        { text: 'Errores de ortografía frecuentes', isCorrect: false },
                        { text: 'Información de contacto y "Acerca de"', isCorrect: true },
                        { text: 'Pide descargar archivos inmediatamente', isCorrect: false }
                    ]
                },
                {
                    question: 'Tu hermano te dice algo que vio en internet. ¿Qué debes hacer?',
                    explanation: 'Aunque confiemos en la persona, siempre es bueno verificar la información por nosotros mismos.',
                    answers: [
                        { text: 'Creerle porque es mi hermano', isCorrect: false },
                        { text: 'Verificar la información yo mismo', isCorrect: true },
                        { text: 'Ignorarlo completamente', isCorrect: false },
                        { text: 'Discutir sin verificar', isCorrect: false }
                    ]
                }
            ]
        },
        {
            id: 'veracidad_memory',
            title: 'Memoria del Detective',
            subtitle: 'Conceptos de verificación',
            type: 'memory',
            icon: 'brain',
            color: 0xFF60A5FA,
            order: 2,
            xpReward: 50,
            cards: [
                { content: '🔎', pair: 'Investigar' },
                { content: '📚', pair: 'Fuente' },
                { content: '✓', pair: 'Verificar' },
                { content: '❓', pair: 'Cuestionar' },
                { content: '📊', pair: 'Evidencia' },
                { content: '🎯', pair: 'Precisión' }
            ]
        },
        {
            id: 'veracidad_quiz_2',
            title: 'Método de Verificación',
            subtitle: 'Técnicas avanzadas',
            type: 'quiz',
            icon: 'clipboard_check',
            color: 0xFF1D4ED8,
            order: 3,
            xpReward: 75,
            questions: [
                {
                    question: '¿Cuál es el primer paso del método SIFT para verificar información?',
                    explanation: 'SIFT: Stop (detente), Investigate (investiga la fuente), Find (encuentra mejor cobertura), Trace (rastrea el origen).',
                    answers: [
                        { text: 'Compartir inmediatamente', isCorrect: false },
                        { text: 'STOP - Detenerse y pensar antes de actuar', isCorrect: true },
                        { text: 'Comentar tu opinión', isCorrect: false },
                        { text: 'Guardar para después', isCorrect: false }
                    ]
                },
                {
                    question: '¿Por qué es importante verificar la fecha de una noticia?',
                    hint: 'La información puede cambiar con el tiempo',
                    explanation: 'Una noticia vieja puede estar desactualizada o ser compartida fuera de contexto como si fuera nueva.',
                    answers: [
                        { text: 'La fecha no importa', isCorrect: false },
                        { text: 'Puede ser información vieja compartida como nueva', isCorrect: true },
                        { text: 'Solo importa para noticias de deportes', isCorrect: false },
                        { text: 'Las noticias nunca tienen fecha', isCorrect: false }
                    ]
                },
                {
                    question: '¿Qué es el "sesgo" en una noticia?',
                    explanation: 'El sesgo es cuando se presenta información favoreciendo un punto de vista sin mostrar todos los lados del tema.',
                    answers: [
                        { text: 'Un error de ortografía', isCorrect: false },
                        { text: 'Cuando se favorece un punto de vista sobre otros', isCorrect: true },
                        { text: 'Una noticia muy larga', isCorrect: false },
                        { text: 'Cuando tiene muchas fotos', isCorrect: false }
                    ]
                },
                {
                    question: '¿Cuántas fuentes diferentes deberías consultar para verificar algo importante?',
                    explanation: 'Tres fuentes diferentes y independientes ayudan a confirmar si la información es verdadera.',
                    answers: [
                        { text: 'Una es suficiente', isCorrect: false },
                        { text: 'Al menos 3 fuentes diferentes', isCorrect: true },
                        { text: 'Solo Wikipedia', isCorrect: false },
                        { text: 'Ninguna, confía en tu instinto', isCorrect: false }
                    ]
                },
                {
                    question: '¿Qué debes hacer si encuentras información contradictoria?',
                    explanation: 'Cuando hay contradicciones, las fuentes más confiables (oficiales, expertas) tienen más peso.',
                    answers: [
                        { text: 'Creer la primera que vi', isCorrect: false },
                        { text: 'Buscar fuentes más confiables y oficiales', isCorrect: true },
                        { text: 'Creer la más interesante', isCorrect: false },
                        { text: 'No creer nada nunca más', isCorrect: false }
                    ]
                }
            ]
        },
        {
            id: 'veracidad_quiz_3',
            title: 'Maestro Verificador',
            subtitle: 'Desafío Final',
            type: 'quiz',
            icon: 'shield',
            color: 0xFF1E40AF,
            order: 4,
            xpReward: 100,
            questions: [
                {
                    question: '¿Qué es una "fuente primaria"?',
                    explanation: 'Las fuentes primarias son documentos o testimonios originales, no interpretaciones de otros.',
                    answers: [
                        { text: 'La primera página de Google', isCorrect: false },
                        { text: 'Información original, no de segunda mano', isCorrect: true },
                        { text: 'La fuente más popular', isCorrect: false },
                        { text: 'Cualquier página de internet', isCorrect: false }
                    ]
                },
                {
                    question: 'Un artículo científico dice "probablemente" y "los resultados sugieren". ¿Es malo?',
                    hint: 'La ciencia es honesta sobre sus limitaciones',
                    explanation: 'La ciencia real es cautelosa. Las fake news suelen ser absolutas ("la cura definitiva", "siempre funciona").',
                    answers: [
                        { text: 'Sí, debería ser más seguro', isCorrect: false },
                        { text: 'No, la ciencia real es cautelosa con sus afirmaciones', isCorrect: true },
                        { text: 'Solo los artículos falsos usan esas palabras', isCorrect: false },
                        { text: 'Significa que el autor no sabe nada', isCorrect: false }
                    ]
                },
                {
                    question: 'Encuentras datos estadísticos en una noticia. ¿Qué debes verificar?',
                    explanation: 'Las estadísticas sin fuente pueden ser inventadas. Siempre verifica de dónde vienen los números.',
                    answers: [
                        { text: 'Si los números son bonitos', isCorrect: false },
                        { text: 'La fuente original de los datos', isCorrect: true },
                        { text: 'Si el autor tiene foto de perfil', isCorrect: false },
                        { text: 'Cuántos likes tiene el artículo', isCorrect: false }
                    ]
                },
                {
                    question: '¿Qué significa que una noticia sea "viral"?',
                    explanation: 'Viral solo significa que se comparte mucho, no que sea verdadera. Muchas fake news se vuelven virales.',
                    answers: [
                        { text: 'Que es automáticamente verdadera', isCorrect: false },
                        { text: 'Que se comparte mucho, sea verdadera o falsa', isCorrect: true },
                        { text: 'Que contiene un virus', isCorrect: false },
                        { text: 'Que fue verificada por expertos', isCorrect: false }
                    ]
                }
            ]
        },
        {
            id: 'veracidad_memory_2',
            title: 'Herramientas del Detective',
            subtitle: 'Recursos de verificación',
            type: 'memory',
            icon: 'tool',
            color: 0xFF3B82F6,
            order: 5,
            xpReward: 75,
            cards: [
                { content: '🔍', pair: 'Google' },
                { content: '🖼️', pair: 'Búsqueda de imagen' },
                { content: '📅', pair: 'Fecha' },
                { content: '👤', pair: 'Autor' },
                { content: '🔗', pair: 'Enlaces' },
                { content: '📖', pair: 'Referencias' }
            ]
        }
    ]
};

// ============================================
// UNIDAD 3: ESTEREOTIPOS
// Romper con prejuicios y estereotipos
// ============================================
const unitEstereotipos = {
    id: 'unit_estereotipos',
    title: 'Rompiendo Estereotipos',
    subtitle: 'Todos somos únicos',
    description: 'Descubre cómo los estereotipos afectan nuestra forma de ver a los demás y aprende a cuestionarlos para crear un mundo más justo e inclusivo.',
    icon: 'users',
    color: '#8B5CF6', // Morado
    order: 3,
    isActive: true,
    totalXp: 300,
    estimatedTime: '15 min',
    classId: null, // Required for global units
    games: [
        {
            id: 'estereotipos_quiz_1',
            title: '¿Qué son los Estereotipos?',
            subtitle: 'Conceptos básicos',
            type: 'quiz',
            icon: 'help_circle',
            color: 0xFF7C3AED,
            order: 1,
            xpReward: 50,
            questions: [
                {
                    question: '¿Qué es un estereotipo?',
                    explanation: 'Un estereotipo es una idea generalizada sobre un grupo que ignora las diferencias individuales de cada persona.',
                    answers: [
                        { text: 'Una idea generalizada sobre un grupo de personas', isCorrect: true },
                        { text: 'Un tipo de música', isCorrect: false },
                        { text: 'Una forma de saludar', isCorrect: false },
                        { text: 'Un deporte extremo', isCorrect: false }
                    ]
                },
                {
                    question: '"Los niños no deben llorar" es un ejemplo de:',
                    hint: 'Piensa en si esto aplica a TODOS los niños',
                    explanation: 'Esta frase es un estereotipo de género que limita la expresión emocional de los niños.',
                    answers: [
                        { text: 'Una regla científica', isCorrect: false },
                        { text: 'Un estereotipo de género', isCorrect: true },
                        { text: 'Una verdad universal', isCorrect: false },
                        { text: 'Un consejo de salud', isCorrect: false }
                    ]
                },
                {
                    question: '¿Por qué los estereotipos son dañinos?',
                    explanation: 'Los estereotipos limitan las oportunidades de las personas y pueden causar discriminación.',
                    answers: [
                        { text: 'No son dañinos, son divertidos', isCorrect: false },
                        { text: 'Limitan a las personas y causan discriminación', isCorrect: true },
                        { text: 'Solo afectan a los adultos', isCorrect: false },
                        { text: 'Ayudan a conocer mejor a otros', isCorrect: false }
                    ]
                },
                {
                    question: '¿Cuál de estas afirmaciones es un estereotipo?',
                    explanation: 'Generalizar características a grupos enteros de personas es un estereotipo.',
                    answers: [
                        { text: 'Mi amigo Juan es bueno en matemáticas', isCorrect: false },
                        { text: 'Todos los asiáticos son buenos en matemáticas', isCorrect: true },
                        { text: 'Las matemáticas son difíciles para mí', isCorrect: false },
                        { text: 'Estudiar matemáticas requiere práctica', isCorrect: false }
                    ]
                },
                {
                    question: '¿De dónde vienen los estereotipos?',
                    explanation: 'Los estereotipos se aprenden de la familia, medios de comunicación, películas y la sociedad en general.',
                    answers: [
                        { text: 'Nacemos con ellos', isCorrect: false },
                        { text: 'Los aprendemos de la sociedad, medios y familia', isCorrect: true },
                        { text: 'Son verdades científicas', isCorrect: false },
                        { text: 'Los inventan los gobiernos', isCorrect: false }
                    ]
                }
            ]
        },
        {
            id: 'estereotipos_memory',
            title: 'Palabras de Inclusión',
            subtitle: 'Conecta valores positivos',
            type: 'memory',
            icon: 'heart',
            color: 0xFFA78BFA,
            order: 2,
            xpReward: 50,
            cards: [
                { content: '🤝', pair: 'Respeto' },
                { content: '❤️', pair: 'Empatía' },
                { content: '🌈', pair: 'Diversidad' },
                { content: '⚖️', pair: 'Igualdad' },
                { content: '🤗', pair: 'Inclusión' },
                { content: '🕊️', pair: 'Paz' }
            ]
        },
        {
            id: 'estereotipos_quiz_2',
            title: 'Género y Profesiones',
            subtitle: 'Rompiendo barreras',
            type: 'quiz',
            icon: 'briefcase',
            color: 0xFF6D28D9,
            order: 3,
            xpReward: 75,
            questions: [
                {
                    question: '¿Las mujeres pueden ser ingenieras o pilotos de avión?',
                    explanation: 'Las profesiones no tienen género. Cualquier persona puede elegir la carrera que desee con la preparación adecuada.',
                    answers: [
                        { text: 'No, son trabajos solo para hombres', isCorrect: false },
                        { text: 'Sí, cualquier persona puede ser lo que quiera', isCorrect: true },
                        { text: 'Solo si son muy fuertes', isCorrect: false },
                        { text: 'Solo en algunos países', isCorrect: false }
                    ]
                },
                {
                    question: '¿Los hombres pueden ser enfermeros o maestros de preescolar?',
                    hint: 'Piensa en las capacidades, no en el género',
                    explanation: 'Cuidar de otros es una habilidad humana, no de un género específico. Los hombres pueden ser excelentes enfermeros y maestros.',
                    answers: [
                        { text: 'No, son trabajos de mujeres', isCorrect: false },
                        { text: 'Sí, son profesiones para cualquier persona', isCorrect: true },
                        { text: 'Solo si no hay mujeres disponibles', isCorrect: false },
                        { text: 'Es raro pero permitido', isCorrect: false }
                    ]
                },
                {
                    question: 'Un niño quiere aprender a cocinar. ¿Qué opinas?',
                    explanation: 'Cocinar es una habilidad de vida importante para todas las personas, sin importar su género.',
                    answers: [
                        { text: 'Cocinar es solo para niñas', isCorrect: false },
                        { text: '¡Excelente! Cocinar es para todos', isCorrect: true },
                        { text: 'Debería jugar fútbol en su lugar', isCorrect: false },
                        { text: 'Solo si quiere ser chef profesional', isCorrect: false }
                    ]
                },
                {
                    question: 'Una niña quiere jugar al fútbol con los niños. ¿Está bien?',
                    explanation: 'El deporte es para todas las personas. Las habilidades deportivas no dependen del género.',
                    answers: [
                        { text: 'No, el fútbol es para niños', isCorrect: false },
                        { text: '¡Claro! El deporte es para todos', isCorrect: true },
                        { text: 'Solo si es muy buena', isCorrect: false },
                        { text: 'Debería jugar voleibol', isCorrect: false }
                    ]
                },
                {
                    question: '¿Los colores tienen género?',
                    explanation: 'Los colores son solo colores. La idea de colores "de niño" o "de niña" es un estereotipo social.',
                    answers: [
                        { text: 'Sí, rosa para niñas y azul para niños', isCorrect: false },
                        { text: 'No, cada persona puede usar el color que quiera', isCorrect: true },
                        { text: 'Depende del país', isCorrect: false },
                        { text: 'Solo algunos colores son neutrales', isCorrect: false }
                    ]
                }
            ]
        },
        {
            id: 'estereotipos_quiz_3',
            title: 'Diversidad Cultural',
            subtitle: 'Un mundo de diferencias',
            type: 'quiz',
            icon: 'globe',
            color: 0xFF5B21B6,
            order: 4,
            xpReward: 75,
            questions: [
                {
                    question: '¿Qué significa "diversidad cultural"?',
                    explanation: 'La diversidad cultural se refiere a las diferentes formas de vida, tradiciones y costumbres de personas de distintos lugares.',
                    answers: [
                        { text: 'Que todos somos iguales', isCorrect: false },
                        { text: 'La variedad de culturas, tradiciones y costumbres', isCorrect: true },
                        { text: 'Un tipo de comida', isCorrect: false },
                        { text: 'Un festival de música', isCorrect: false }
                    ]
                },
                {
                    question: 'Alguien dice "todas las personas de ese país son iguales". ¿Es correcto?',
                    hint: 'Piensa en la variedad de personas que conoces',
                    explanation: 'En cada país hay millones de personas diferentes. Generalizar a todas es un estereotipo.',
                    answers: [
                        { text: 'Sí, la nacionalidad define la personalidad', isCorrect: false },
                        { text: 'No, en cada país hay personas muy diferentes', isCorrect: true },
                        { text: 'Depende del país', isCorrect: false },
                        { text: 'Solo en países pequeños', isCorrect: false }
                    ]
                },
                {
                    question: '¿Cómo reaccionas cuando conoces a alguien de otra cultura?',
                    explanation: 'La curiosidad respetuosa nos ayuda a aprender y a conectar con personas diferentes a nosotros.',
                    answers: [
                        { text: 'Asumo que es como los estereotipos que conozco', isCorrect: false },
                        { text: 'Con curiosidad y respeto para conocerla', isCorrect: true },
                        { text: 'Evito hablarle', isCorrect: false },
                        { text: 'Le digo que se adapte a mi cultura', isCorrect: false }
                    ]
                },
                {
                    question: '¿Por qué es importante conocer otras culturas?',
                    explanation: 'Conocer otras culturas nos hace más tolerantes, creativos y nos ayuda a entender mejor el mundo.',
                    answers: [
                        { text: 'No es importante', isCorrect: false },
                        { text: 'Para ser más tolerantes y aprender cosas nuevas', isCorrect: true },
                        { text: 'Solo si vamos a viajar', isCorrect: false },
                        { text: 'Para criticarlas', isCorrect: false }
                    ]
                }
            ]
        },
        {
            id: 'estereotipos_quiz_4',
            title: 'Agente del Cambio',
            subtitle: 'Desafío Final',
            type: 'quiz',
            icon: 'star',
            color: 0xFF4C1D95,
            order: 5,
            xpReward: 50,
            questions: [
                {
                    question: '¿Qué puedes hacer cuando escuchas un comentario estereotipado?',
                    hint: 'Piensa en cómo ayudar a cambiar las cosas',
                    explanation: 'Cuestionar respetuosamente ayuda a las personas a reflexionar sobre sus prejuicios.',
                    answers: [
                        { text: 'Reírme aunque me incomode', isCorrect: false },
                        { text: 'Preguntar amablemente por qué piensa eso', isCorrect: true },
                        { text: 'Ignorarlo siempre', isCorrect: false },
                        { text: 'Repetir el comentario a otros', isCorrect: false }
                    ]
                },
                {
                    question: '¿Cómo puedes ser más inclusivo en tu vida diaria?',
                    explanation: 'La inclusión comienza con acciones simples como incluir a todos, escuchar y tratar a todos con respeto.',
                    answers: [
                        { text: 'Juntándome solo con gente parecida a mí', isCorrect: false },
                        { text: 'Incluyendo a todos, escuchando y respetando diferencias', isCorrect: true },
                        { text: 'Evitando a quienes son diferentes', isCorrect: false },
                        { text: 'No hablando de diferencias', isCorrect: false }
                    ]
                },
                {
                    question: '¿Qué aprendiste hoy sobre los estereotipos?',
                    explanation: '¡Felicidades! Ahora eres un agente del cambio que puede ayudar a crear un mundo más justo.',
                    answers: [
                        { text: 'Que todos los estereotipos son verdad', isCorrect: false },
                        { text: 'Que debo cuestionar las generalizaciones', isCorrect: true },
                        { text: 'Que no puedo cambiar nada', isCorrect: false },
                        { text: 'Que es mejor no pensar en esto', isCorrect: false }
                    ]
                }
            ]
        }
    ]
};

// ============================================
// FUNCIÓN PRINCIPAL
// ============================================
async function createUnits() {
    console.log('🎮 Creando las 3 unidades principales de PiensaPlay...\n');

    try {
        // Primero eliminar las unidades anteriores
        console.log('🗑️  Limpiando unidades anteriores...');
        const existingUnits = await getDocs(collection(db, 'game_units'));
        for (const docSnap of existingUnits.docs) {
            await deleteDoc(docSnap.ref);
        }
        console.log(`   ✓ ${existingUnits.size} unidades eliminadas\n`);

        // Crear las 3 unidades
        console.log('📚 Creando unidades nuevas...\n');

        // Unidad 1: Fake News
        console.log('🔴 UNIDAD 1: ¡Alerta Fake News!');
        await setDoc(doc(db, 'game_units', unitFakeNews.id), unitFakeNews);
        console.log(`   ✓ ${unitFakeNews.games.length} actividades creadas`);
        console.log(`   ✓ XP Total: ${unitFakeNews.totalXp}\n`);

        // Unidad 2: Veracidad
        console.log('🔵 UNIDAD 2: Detectives de la Verdad');
        await setDoc(doc(db, 'game_units', unitVeracidad.id), unitVeracidad);
        console.log(`   ✓ ${unitVeracidad.games.length} actividades creadas`);
        console.log(`   ✓ XP Total: ${unitVeracidad.totalXp}\n`);

        // Unidad 3: Estereotipos
        console.log('🟣 UNIDAD 3: Rompiendo Estereotipos');
        await setDoc(doc(db, 'game_units', unitEstereotipos.id), unitEstereotipos);
        console.log(`   ✓ ${unitEstereotipos.games.length} actividades creadas`);
        console.log(`   ✓ XP Total: ${unitEstereotipos.totalXp}\n`);

        // Resumen
        const totalActivities = unitFakeNews.games.length + unitVeracidad.games.length + unitEstereotipos.games.length;
        const totalQuestions =
            unitFakeNews.games.reduce((acc, g) => acc + (g.questions?.length || 0), 0) +
            unitVeracidad.games.reduce((acc, g) => acc + (g.questions?.length || 0), 0) +
            unitEstereotipos.games.reduce((acc, g) => acc + (g.questions?.length || 0), 0);

        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('✅ UNIDADES CREADAS EXITOSAMENTE');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log(`\n📊 Resumen:`);
        console.log(`   • 3 Unidades temáticas`);
        console.log(`   • ${totalActivities} Actividades totales`);
        console.log(`   • ${totalQuestions} Preguntas de quiz`);
        console.log(`   • 950 XP disponibles para ganar`);
        console.log(`\n🎯 Temas cubiertos:`);
        console.log(`   1. Fake News - Detectar desinformación`);
        console.log(`   2. Veracidad - Verificar información`);
        console.log(`   3. Estereotipos - Inclusión y diversidad\n`);

    } catch (error) {
        console.error('❌ Error:', error);
    }

    process.exit(0);
}

createUnits();
