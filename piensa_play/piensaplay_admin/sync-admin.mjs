// Script para sincronizar usuarios entre Firebase Auth y Firestore
// Y añadir tags a los estudiantes
// Ejecutar con: node sync-admin.mjs

import { initializeApp } from 'firebase/app';
import {
    getFirestore,
    collection,
    doc,
    setDoc,
    getDocs,
    deleteDoc,
    updateDoc,
    query,
    where
} from 'firebase/firestore';

// Firebase config - usar variables de entorno
// IMPORTANTE: Configurar estas variables antes de ejecutar el script
// O crear un archivo .env con estos valores
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

// UID del admin creado en Firebase Authentication
const ADMIN_AUTH_UID = 'dBt3AbPEI4gFPGcdjF8AeSWMcXI2';

// Función para generar un tag único (6 caracteres hexadecimales)
function generateTag() {
    return Math.random().toString(16).substring(2, 8).toUpperCase();
}

async function syncData() {
    console.log('🔄 Sincronizando datos...\n');

    try {
        // 1. Eliminar el documento admin_001 viejo y crear uno con el UID correcto
        console.log('👑 Actualizando usuario admin...');

        // Eliminar el documento con ID incorrecto si existe
        try {
            await deleteDoc(doc(db, 'users', 'admin_001'));
            console.log('   ✓ Documento admin_001 eliminado');
        } catch (e) {
            console.log('   (admin_001 no existía)');
        }

        // Crear el admin con el UID correcto de Firebase Auth
        await setDoc(doc(db, 'users', ADMIN_AUTH_UID), {
            email: 'admin@piensaplay.com',
            name: 'Administrador Principal',
            role: 'superadmin',
            createdAt: new Date('2024-01-01'),
            avatarIndex: 0
        });
        console.log(`   ✓ Admin creado con UID: ${ADMIN_AUTH_UID}\n`);

        // 2. Actualizar estudiantes con tags únicos
        console.log('🏷️  Añadiendo tags a estudiantes...');

        const studentsQuery = await getDocs(collection(db, 'users'));
        const students = studentsQuery.docs.filter(d => {
            const data = d.data();
            return !data.role || data.role === 'student';
        });

        for (const student of students) {
            const tag = generateTag();
            await updateDoc(doc(db, 'users', student.id), {
                tag: tag,
                role: 'student' // Asegurarnos que tengan rol explícito
            });
            console.log(`   ✓ ${student.data().name}: #${tag}`);
        }

        console.log(`\n   Total: ${students.length} estudiantes con tags\n`);

        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('✅ SINCRONIZACIÓN COMPLETADA');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('\n🔐 Credenciales de acceso al panel admin:');
        console.log('   Email: admin@piensaplay.com');
        console.log('   Contraseña: Admin2024!');
        console.log('\n');

    } catch (error) {
        console.error('❌ Error:', error);
    }

    process.exit(0);
}

syncData();
