// Script para limpiar y poblar Firebase con datos de prueba coherentes
// Ejecutar con: node seed-database.mjs

import { initializeApp } from 'firebase/app';
import {
    getFirestore,
    collection,
    doc,
    setDoc,
    getDocs,
    deleteDoc,
    writeBatch
} from 'firebase/firestore';

// Firebase config - usar variables de entorno para seguridad
const firebaseConfig = {
    apiKey: process.env.FIREBASE_API_KEY || "YOUR_API_KEY_HERE",
    authDomain: process.env.FIREBASE_AUTH_DOMAIN || "piensa-play-56a1c.firebaseapp.com",
    projectId: process.env.FIREBASE_PROJECT_ID || "piensa-play-56a1c",
    storageBucket: process.env.FIREBASE_STORAGE_BUCKET || "piensa-play-56a1c.appspot.com",
    messagingSenderId: process.env.FIREBASE_MESSAGING_SENDER_ID || "738250464476",
    appId: process.env.FIREBASE_APP_ID || "YOUR_APP_ID_HERE"
};

const app = initializeApp(firebaseConfig);
const db = getFirestore(app);

// ============================================
// HELPER: Limpiar una colección completa
// ============================================
async function clearCollection(collectionName) {
    console.log(`🗑️  Limpiando colección: ${collectionName}...`);
    const querySnapshot = await getDocs(collection(db, collectionName));
    const batch = writeBatch(db);
    querySnapshot.docs.forEach((document) => {
        batch.delete(document.ref);
    });
    await batch.commit();
    console.log(`   ✓ ${querySnapshot.size} documentos eliminados`);
}

// ============================================
// DATOS DE SEED
// ============================================

// Configuración global de la app
const appConfig = {
    initialWalletBalance: 100,
    xpPerActivity: 50,
    coinsPerActivity: 15,
    enableShop: true,
    enableGlossary: true,
    maintenanceMode: false
};

// Usuarios: 1 Admin, 2 Tutores, 8 Estudiantes
const users = [
    // Administrador
    {
        id: 'admin_001',
        email: 'admin@piensaplay.com',
        name: 'Administrador Principal',
        role: 'superadmin',
        createdAt: new Date('2024-01-01'),
        avatarIndex: 0
    },
    // Tutores
    {
        id: 'tutor_001',
        email: 'maria.gonzalez@colegio.edu',
        name: 'María González',
        role: 'tutor',
        createdAt: new Date('2024-02-15'),
        specialty: 'Pensamiento Crítico',
        avatarIndex: 1
    },
    {
        id: 'tutor_002',
        email: 'carlos.mendez@colegio.edu',
        name: 'Carlos Méndez',
        role: 'tutor',
        createdAt: new Date('2024-03-01'),
        specialty: 'Educación Digital',
        avatarIndex: 2
    },
    // Estudiantes (jugadores)
    {
        id: 'student_001',
        email: 'sofia.lopez@estudiante.edu',
        name: 'Sofía López',
        age: 12,
        totalXp: 2450,
        walletBalance: 185,
        gamesCompleted: 28,
        avatarIndex: 3,
        equippedAvatarUrl: 'https://res.cloudinary.com/dpg6zisqx/image/upload/v1/piensaplay/avatar_cosmic.png',
        createdAt: new Date('2024-03-10'),
        lastActiveAt: new Date()
    },
    {
        id: 'student_002',
        email: 'diego.martinez@estudiante.edu',
        name: 'Diego Martínez',
        age: 11,
        totalXp: 2180,
        walletBalance: 120,
        gamesCompleted: 24,
        avatarIndex: 4,
        createdAt: new Date('2024-03-12'),
        lastActiveAt: new Date()
    },
    {
        id: 'student_003',
        email: 'valentina.ruiz@estudiante.edu',
        name: 'Valentina Ruiz',
        age: 13,
        totalXp: 1950,
        walletBalance: 95,
        gamesCompleted: 21,
        avatarIndex: 5,
        createdAt: new Date('2024-03-15'),
        lastActiveAt: new Date()
    },
    {
        id: 'student_004',
        email: 'mateo.hernandez@estudiante.edu',
        name: 'Mateo Hernández',
        age: 12,
        totalXp: 1720,
        walletBalance: 200,
        gamesCompleted: 18,
        avatarIndex: 6,
        createdAt: new Date('2024-03-18'),
        lastActiveAt: new Date()
    },
    {
        id: 'student_005',
        email: 'camila.torres@estudiante.edu',
        name: 'Camila Torres',
        age: 11,
        totalXp: 1540,
        walletBalance: 75,
        gamesCompleted: 16,
        avatarIndex: 7,
        createdAt: new Date('2024-03-20'),
        lastActiveAt: new Date()
    },
    {
        id: 'student_006',
        email: 'sebastian.castro@estudiante.edu',
        name: 'Sebastián Castro',
        age: 12,
        totalXp: 1320,
        walletBalance: 145,
        gamesCompleted: 14,
        avatarIndex: 3,
        createdAt: new Date('2024-04-01'),
        lastActiveAt: new Date()
    },
    {
        id: 'student_007',
        email: 'lucia.morales@estudiante.edu',
        name: 'Lucía Morales',
        age: 13,
        totalXp: 980,
        walletBalance: 60,
        gamesCompleted: 10,
        avatarIndex: 4,
        createdAt: new Date('2024-04-05'),
        lastActiveAt: new Date()
    },
    {
        id: 'student_008',
        email: 'andres.silva@estudiante.edu',
        name: 'Andrés Silva',
        age: 11,
        totalXp: 650,
        walletBalance: 110,
        gamesCompleted: 7,
        avatarIndex: 5,
        createdAt: new Date('2024-04-10'),
        lastActiveAt: new Date()
    }
];

// Unidades de juego con actividades
const gameUnits = [
    {
        id: 'unit_fake_news',
        title: 'Detectives de la Información',
        subtitle: 'Aprende a identificar noticias falsas',
        description: 'En esta aventura aprenderás a distinguir información real de la falsa y desarrollarás habilidades de pensamiento crítico.',
        icon: 'search',
        color: 0xFF6366F1,
        order: 1,
        isActive: true,
        games: [
            {
                id: 'activity_1_1',
                title: '¿Real o Falso?',
                subtitle: 'Primera misión',
                type: 'fake_news',
                icon: 'newspaper',
                color: 0xFFEC4899,
                media: { image: null, audio: null, video: null },
                questions: [
                    {
                        id: 'q1',
                        headline: 'Científicos descubren que el chocolate cura todas las enfermedades',
                        source: 'noticiasincreibles.com',
                        isReal: false,
                        explanation: 'Ningún alimento puede curar "todas" las enfermedades. Esta afirmación exagerada es típica de noticias falsas.'
                    },
                    {
                        id: 'q2',
                        headline: 'La OMS recomienda lavarse las manos frecuentemente para prevenir enfermedades',
                        source: 'who.int',
                        isReal: true,
                        explanation: 'Esta es información verificada de la Organización Mundial de la Salud, una fuente confiable.'
                    },
                    {
                        id: 'q3',
                        headline: 'El 5G causa mutaciones en las plantas',
                        source: 'verdadescultas.net',
                        isReal: false,
                        explanation: 'No hay evidencia científica que respalde esta afirmación. El dominio ".net" y el nombre del sitio son señales de alerta.'
                    },
                    {
                        id: 'q4',
                        headline: 'El ejercicio regular mejora la salud mental según estudios',
                        source: 'National Institutes of Health',
                        isReal: true,
                        explanation: 'Múltiples estudios científicos respaldan los beneficios del ejercicio para la salud mental.'
                    }
                ]
            },
            {
                id: 'activity_1_2',
                title: 'Fuentes Confiables',
                subtitle: 'Aprende a verificar',
                type: 'quiz',
                icon: 'checkCircle',
                color: 0xFF10B981,
                media: { image: null, audio: null, video: null },
                questions: [
                    {
                        id: 'q1',
                        text: '¿Cuál de estas es una señal de una noticia falsa?',
                        options: ['Tiene autor identificado', 'Usa muchos signos de exclamación!!!', 'Cita fuentes oficiales', 'Tiene fecha reciente'],
                        correctIndex: 1
                    },
                    {
                        id: 'q2',
                        text: '¿Qué debes hacer antes de compartir una noticia?',
                        options: ['Compartir inmediatamente', 'Verificar en otras fuentes', 'Leer solo el título', 'Confiar en quien te la envió'],
                        correctIndex: 1
                    },
                    {
                        id: 'q3',
                        text: '¿Cuál es una fuente más confiable?',
                        options: ['Un blog personal', 'Un mensaje de WhatsApp', 'Una organización oficial', 'Un video de TikTok'],
                        correctIndex: 2
                    }
                ]
            }
        ]
    },
    {
        id: 'unit_stereotypes',
        title: 'Rompiendo Estereotipos',
        subtitle: 'Todos somos únicos',
        description: 'Descubre cómo los estereotipos afectan nuestra forma de ver el mundo y aprende a cuestionarlos.',
        icon: 'users',
        color: 0xFF8B5CF6,
        order: 2,
        isActive: true,
        games: [
            {
                id: 'activity_2_1',
                title: '¿Quién puede ser qué?',
                subtitle: 'Profesiones sin límites',
                type: 'stereotype_breaker',
                icon: 'sparkles',
                color: 0xFF00BCD4,
                media: { image: null, audio: null, video: null },
                questions: [
                    {
                        id: 'q1',
                        statement: 'Solo los hombres pueden ser bomberos',
                        isStereotype: true,
                        correction: 'Cualquier persona con la capacitación adecuada puede ser bombero, sin importar su género.'
                    },
                    {
                        id: 'q2',
                        statement: 'Las personas de cualquier edad pueden aprender a programar',
                        isStereotype: false,
                        correction: 'Correcto! El aprendizaje no tiene límite de edad.'
                    },
                    {
                        id: 'q3',
                        statement: 'Los niños no deben jugar con muñecas',
                        isStereotype: true,
                        correction: 'Los juguetes no tienen género. Jugar con muñecas puede ayudar a desarrollar empatía y habilidades de cuidado.'
                    }
                ]
            },
            {
                id: 'activity_2_2',
                title: 'Emparejar Realidades',
                subtitle: 'Conecta conceptos',
                type: 'match_pairs',
                icon: 'link',
                color: 0xFF66BB6A,
                media: { image: null, audio: null, video: null },
                questions: [
                    { id: 'q1', leftItem: 'Estereotipo', rightItem: 'Idea generalizada sobre un grupo' },
                    { id: 'q2', leftItem: 'Diversidad', rightItem: 'Variedad de características en un grupo' },
                    { id: 'q3', leftItem: 'Inclusión', rightItem: 'Aceptar a todos sin importar diferencias' },
                    { id: 'q4', leftItem: 'Prejuicio', rightItem: 'Opinión sin conocimiento real' }
                ]
            }
        ]
    },
    {
        id: 'unit_critical_thinking',
        title: 'Pensadores Brillantes',
        subtitle: 'Desarrolla tu mente crítica',
        description: 'Aprende a analizar información, hacer preguntas importantes y tomar mejores decisiones.',
        icon: 'brain',
        color: 0xFFF59E0B,
        order: 3,
        isActive: true,
        games: [
            {
                id: 'activity_3_1',
                title: 'Ordena el Proceso',
                subtitle: 'Pasos del pensamiento crítico',
                type: 'order_sequence',
                icon: 'list',
                color: 0xFF26A69A,
                media: { image: null, audio: null, video: null },
                questions: [
                    {
                        id: 'q1',
                        title: 'Proceso de verificación de información',
                        items: [
                            'Leer la noticia completa',
                            'Identificar la fuente',
                            'Buscar en otras fuentes',
                            'Analizar la evidencia',
                            'Sacar una conclusión'
                        ],
                        correctOrder: [0, 1, 2, 3, 4]
                    }
                ]
            },
            {
                id: 'activity_3_2',
                title: 'Memoria Crítica',
                subtitle: 'Recuerda los conceptos',
                type: 'memory',
                icon: 'brain',
                color: 0xFFAB47BC,
                media: { image: null, audio: null, video: null },
                questions: [
                    { id: 'q1', cardA: { text: 'Fuente primaria' }, cardB: { text: 'Información de primera mano' } },
                    { id: 'q2', cardA: { text: 'Sesgo' }, cardB: { text: 'Tendencia a favor o en contra' } },
                    { id: 'q3', cardA: { text: 'Verificar' }, cardB: { text: 'Comprobar si algo es verdad' } },
                    { id: 'q4', cardA: { text: 'Evidencia' }, cardB: { text: 'Prueba que apoya una idea' } }
                ]
            }
        ]
    }
];

// Avatares para la tienda
const shopItems = [
    {
        id: 'avatar_cosmic',
        name: 'Explorador Cósmico',
        description: 'Un viajero de las estrellas',
        price: 150,
        rarity: 'epic',
        color: '#8b5cf6',
        type: 'avatar',
        imageUrl: 'https://res.cloudinary.com/dpg6zisqx/image/upload/v1/piensaplay/avatar_sample.png'
    },
    {
        id: 'avatar_nature',
        name: 'Guardián Natural',
        description: 'Protector de la naturaleza',
        price: 100,
        rarity: 'rare',
        color: '#10b981',
        type: 'avatar',
        imageUrl: 'https://res.cloudinary.com/dpg6zisqx/image/upload/v1/piensaplay/avatar_sample.png'
    },
    {
        id: 'avatar_tech',
        name: 'Genio Digital',
        description: 'Maestro de la tecnología',
        price: 200,
        rarity: 'legendary',
        color: '#6366f1',
        type: 'avatar',
        imageUrl: 'https://res.cloudinary.com/dpg6zisqx/image/upload/v1/piensaplay/avatar_sample.png'
    },
    {
        id: 'avatar_fire',
        name: 'Espíritu de Fuego',
        description: 'Energía y pasión',
        price: 75,
        rarity: 'common',
        color: '#ef4444',
        type: 'avatar',
        imageUrl: 'https://res.cloudinary.com/dpg6zisqx/image/upload/v1/piensaplay/avatar_sample.png'
    }
];

// Avatares por defecto (selección inicial)
const defaultAvatars = [
    { id: 'default_1', name: 'Estudiante Curioso', color: '#6366f1', imageUrl: '', isDefault: true },
    { id: 'default_2', name: 'Pequeño Científico', color: '#10b981', imageUrl: '', isDefault: true },
    { id: 'default_3', name: 'Artista Creativo', color: '#f59e0b', imageUrl: '', isDefault: true },
    { id: 'default_4', name: 'Deportista Estrella', color: '#ef4444', imageUrl: '', isDefault: true }
];

// Glosario de términos
const glossaryTerms = [
    {
        id: 'term_fake_news',
        term: 'Fake News',
        definition: 'Información falsa presentada como si fuera una noticia real, diseñada para engañar a las personas.',
        category: 'Alfabetización Mediática',
        example: 'Una publicación en redes sociales que dice que un famoso murió cuando en realidad está vivo.'
    },
    {
        id: 'term_stereotype',
        term: 'Estereotipo',
        definition: 'Una idea generalizada y simplificada sobre un grupo de personas que no considera las diferencias individuales.',
        category: 'Convivencia',
        example: 'Pensar que todas las personas de un país actúan de la misma manera.'
    },
    {
        id: 'term_critical_thinking',
        term: 'Pensamiento Crítico',
        definition: 'La habilidad de analizar información de manera objetiva y tomar decisiones basadas en evidencia.',
        category: 'Habilidades Cognitivas',
        example: 'Antes de creer algo, investigar si hay pruebas que lo respalden.'
    },
    {
        id: 'term_source',
        term: 'Fuente de Información',
        definition: 'El origen de donde proviene una noticia o dato. Puede ser confiable o no confiable.',
        category: 'Alfabetización Mediática',
        example: 'Una universidad, un periódico reconocido, o una organización oficial.'
    },
    {
        id: 'term_bias',
        term: 'Sesgo',
        definition: 'Una tendencia a favor o en contra de algo, que puede afectar cómo se presenta la información.',
        category: 'Alfabetización Mediática',
        example: 'Un artículo que solo muestra los aspectos negativos de un tema sin mencionar los positivos.'
    },
    {
        id: 'term_empathy',
        term: 'Empatía',
        definition: 'La capacidad de entender y compartir los sentimientos de otra persona.',
        category: 'Convivencia',
        example: 'Sentirse triste cuando un amigo está pasando por un momento difícil.'
    }
];

// Clases
const classes = [
    {
        id: 'class_6a',
        name: '6° A - Mañana',
        description: 'Clase de sexto grado, turno mañana',
        tutorId: 'tutor_001',
        tutorName: 'María González',
        studentCount: 4,
        createdAt: new Date('2024-02-20')
    },
    {
        id: 'class_6b',
        name: '6° B - Tarde',
        description: 'Clase de sexto grado, turno tarde',
        tutorId: 'tutor_002',
        tutorName: 'Carlos Méndez',
        studentCount: 4,
        createdAt: new Date('2024-03-05')
    }
];

// ============================================
// FUNCIÓN PRINCIPAL DE SEED
// ============================================
async function seedDatabase() {
    console.log('🚀 Iniciando limpieza y población de base de datos...\n');

    try {
        // 1. Limpiar colecciones existentes
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('FASE 1: Limpiando datos existentes');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

        await clearCollection('users');
        await clearCollection('game_units');
        await clearCollection('shop_items');
        await clearCollection('default_avatars');
        await clearCollection('glossary');
        await clearCollection('classes');
        await clearCollection('tutors');
        await clearCollection('user_progress');

        console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('FASE 2: Poblando con nuevos datos');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

        // 2. Configuración de la app
        console.log('⚙️  Configurando app_config...');
        await setDoc(doc(db, 'app_config', 'general'), appConfig);
        console.log('   ✓ Configuración guardada\n');

        // 3. Usuarios
        console.log('👥 Creando usuarios...');
        for (const user of users) {
            await setDoc(doc(db, 'users', user.id), user);
        }
        console.log(`   ✓ ${users.length} usuarios creados\n`);

        // 4. Unidades de juego
        console.log('🎮 Creando unidades de juego...');
        for (const unit of gameUnits) {
            await setDoc(doc(db, 'game_units', unit.id), unit);
        }
        console.log(`   ✓ ${gameUnits.length} unidades creadas\n`);

        // 5. Items de tienda
        console.log('🛒 Creando items de tienda...');
        for (const item of shopItems) {
            await setDoc(doc(db, 'shop_items', item.id), item);
        }
        console.log(`   ✓ ${shopItems.length} items creados\n`);

        // 6. Avatares por defecto
        console.log('👤 Creando avatares por defecto...');
        for (const avatar of defaultAvatars) {
            await setDoc(doc(db, 'default_avatars', avatar.id), avatar);
        }
        console.log(`   ✓ ${defaultAvatars.length} avatares creados\n`);

        // 7. Glosario
        console.log('📚 Creando glosario...');
        for (const term of glossaryTerms) {
            await setDoc(doc(db, 'glossary', term.id), term);
        }
        console.log(`   ✓ ${glossaryTerms.length} términos creados\n`);

        // 8. Clases
        console.log('🏫 Creando clases...');
        for (const classItem of classes) {
            await setDoc(doc(db, 'classes', classItem.id), classItem);
        }
        console.log(`   ✓ ${classes.length} clases creadas\n`);

        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('✅ BASE DE DATOS POBLADA EXITOSAMENTE');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('\n📊 Resumen:');
        console.log(`   • ${users.filter(u => u.role === 'superadmin').length} Administrador(es)`);
        console.log(`   • ${users.filter(u => u.role === 'tutor').length} Tutor(es)`);
        console.log(`   • ${users.filter(u => !u.role).length} Estudiante(s)`);
        console.log(`   • ${gameUnits.length} Unidades de juego`);
        console.log(`   • ${gameUnits.reduce((acc, u) => acc + (u.games?.length || 0), 0)} Actividades totales`);
        console.log(`   • ${shopItems.length} Items en tienda`);
        console.log(`   • ${glossaryTerms.length} Términos en glosario`);
        console.log(`   • ${classes.length} Clases`);

    } catch (error) {
        console.error('❌ Error durante la población:', error);
    }

    process.exit(0);
}

// Ejecutar
seedDatabase();
