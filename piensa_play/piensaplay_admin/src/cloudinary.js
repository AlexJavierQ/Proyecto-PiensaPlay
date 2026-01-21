// Cloudinary Configuration
// Para configurar:
// 1. Ve a https://cloudinary.com y crea una cuenta gratuita
// 2. En el Dashboard, copia tu "Cloud Name"
// 3. Ve a Settings > Upload > Upload Presets
// 4. Crea un nuevo preset con "Signing Mode: Unsigned" y nombre "piensaplay_uploads"
// 5. Reemplaza CLOUD_NAME abajo con tu cloud name

export const CLOUDINARY_CONFIG = {
    cloudName: 'dpg6zisqx', // Tu Cloud Name
    uploadPreset: 'piensaplay_uploads', // Nombre del preset sin firma
    folder: 'piensaplay', // Carpeta donde se guardarán las imágenes
};

// Función para subir archivos a Cloudinary
export const uploadToCloudinary = async (file, onProgress) => {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', CLOUDINARY_CONFIG.uploadPreset);
    formData.append('folder', CLOUDINARY_CONFIG.folder);

    return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();

        xhr.upload.addEventListener('progress', (event) => {
            if (event.lengthComputable && onProgress) {
                const progress = Math.round((event.loaded / event.total) * 100);
                onProgress(progress);
            }
        });

        xhr.addEventListener('load', () => {
            if (xhr.status >= 200 && xhr.status < 300) {
                const response = JSON.parse(xhr.responseText);
                resolve({
                    url: response.secure_url,
                    publicId: response.public_id,
                    format: response.format,
                    width: response.width,
                    height: response.height
                });
            } else {
                reject(new Error(`Upload failed: ${xhr.statusText}`));
            }
        });

        xhr.addEventListener('error', () => {
            reject(new Error('Network error during upload'));
        });

        xhr.open('POST', `https://api.cloudinary.com/v1_1/${CLOUDINARY_CONFIG.cloudName}/auto/upload`);
        xhr.send(formData);
    });
};

// Función para eliminar archivos de Cloudinary (requiere backend para firma)
// Por ahora solo retornamos true - la eliminación real requiere backend
export const deleteFromCloudinary = async (publicId) => {
    console.log('Delete requested for:', publicId);
    // En producción, harías una llamada a tu backend para eliminar
    return true;
};
