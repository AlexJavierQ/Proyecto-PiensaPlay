// Script para configurar CORS en Firebase Storage
// Ejecutar: node apply-cors.js

async function applyCors() {
    console.log('🚀 Aplicando configuración CORS a Firebase Storage...');

    // Importar dinámicamente
    const { Storage } = await import('@google-cloud/storage');

    // Configuración CORS permisiva
    const corsConfiguration = [
        {
            origin: ['*'],
            method: ['GET', 'POST', 'PUT', 'DELETE', 'HEAD', 'OPTIONS'],
            responseHeader: [
                'Content-Type',
                'Content-Length',
                'x-goog-resumable',
                'Authorization',
                'X-Requested-With',
                'Access-Control-Allow-Origin'
            ],
            maxAgeSeconds: 3600
        }
    ];

    try {
        // Intentar con credenciales de aplicación por defecto
        const storage = new Storage({
            projectId: 'piensa-play-56a1c'
        });

        const bucket = storage.bucket('piensa-play-56a1c.appspot.com');

        await bucket.setCorsConfiguration(corsConfiguration);

        console.log('✅ ¡CORS configurado exitosamente!');
        console.log('📝 Configuración aplicada:', JSON.stringify(corsConfiguration, null, 2));
        console.log('\n🎉 Ahora puedes subir imágenes desde localhost:5173');

    } catch (error) {
        console.error('❌ Error:', error.message);
        console.log('\n🔧 Solución alternativa:');
        console.log('1. Ve a: https://console.cloud.google.com/storage/browser/piensa-play-56a1c.appspot.com');
        console.log('2. Click en "Configuración" (ícono de engranaje)');
        console.log('3. Busca la sección "Interoperabilidad" o "CORS"');
        console.log('4. Pega esta configuración:');
        console.log(JSON.stringify(corsConfiguration, null, 2));
    }
}

applyCors();
