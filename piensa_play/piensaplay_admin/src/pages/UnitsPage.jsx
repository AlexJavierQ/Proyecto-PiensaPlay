import React, { useState, useEffect, useRef } from 'react';
import { db, storage } from '../firebase';
import { collection, query, where, onSnapshot, addDoc, updateDoc, doc, deleteDoc } from 'firebase/firestore';
import { ref, uploadBytesResumable, getDownloadURL, deleteObject } from 'firebase/storage';
import {
    Gamepad2, Plus, Edit2, Trash2, MapPin, Layers,
    ChevronDown, ChevronUp, Play, Image, Music, Video,
    Upload, X, Check, AlertCircle, Loader2, Eye, FileQuestion
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import './UnitsPage.css';

const ACTIVITY_TYPES = [
    { value: 'quiz', label: '🎯 Quiz', color: '#42a5f5', description: 'Preguntas de opción múltiple' },
    { value: 'memory', label: '🧠 Memoria', color: '#ab47bc', description: 'Encuentra los pares iguales' },
    { value: 'match_pairs', label: '🔗 Emparejar', color: '#66bb6a', description: 'Conecta elementos relacionados' },
    { value: 'order_sequence', label: '📋 Ordenar', color: '#26a69a', description: 'Ordena los elementos correctamente' },
    { value: 'fill_blanks', label: '✏️ Completar', color: '#ff7043', description: 'Completa los espacios en blanco' },
    { value: 'word_selection', label: '🛤️ Sendero', color: '#fbbf24', description: 'Selecciona las palabras correctas' },
    { value: 'fake_news', label: '📰 Fake News', color: '#ec407a', description: 'Identifica noticias falsas' },
    { value: 'stereotype_breaker', label: '🌈 Estereotipos', color: '#00bcd4', description: 'Rompe con los estereotipos' },
];

const MEDIA_TYPES = {
    image: { accept: 'image/*', icon: Image, label: 'Imagen', folder: 'images' },
    audio: { accept: 'audio/*', icon: Music, label: 'Audio', folder: 'audios' },
    video: { accept: 'video/*', icon: Video, label: 'Video', folder: 'videos' }
};

const UnitsPage = () => {
    const [units, setUnits] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingUnit, setEditingUnit] = useState(null);
    const [expandedUnit, setExpandedUnit] = useState(null);

    // Activity Modal State
    const [showActivityModal, setShowActivityModal] = useState(false);
    const [editingActivity, setEditingActivity] = useState(null);
    const [activityUnitId, setActivityUnitId] = useState(null);
    const [activeTab, setActiveTab] = useState('general');
    const [activityForm, setActivityForm] = useState({
        title: '',
        subtitle: '',
        type: 'quiz',
        icon: 'games',
        color: 0xFF42A5F5,
        media: { image: null, audio: null, video: null },
        questions: [],
        instructions: ''
    });

    // Upload State
    const [uploadProgress, setUploadProgress] = useState({});
    const [uploading, setUploading] = useState({});
    const fileInputRefs = {
        image: useRef(null),
        audio: useRef(null),
        video: useRef(null)
    };

    useEffect(() => {
        const q = query(collection(db, 'game_units'), where('classId', '==', null));
        const unsubscribe = onSnapshot(q, (snapshot) => {
            const unitsData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setUnits(unitsData.sort((a, b) => (a.order || 0) - (b.order || 0)));
            setLoading(false);
        });
        return () => unsubscribe();
    }, []);

    const handleDelete = async (id) => {
        if (window.confirm('¿Estás seguro de que deseas eliminar esta unidad?')) {
            try {
                await deleteDoc(doc(db, 'game_units', id));
            } catch (error) {
                console.error("Error deleting unit: ", error);
            }
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const unitData = {
            title: formData.get('title'),
            subtitle: formData.get('subtitle'),
            color: formData.get('color'),
            order: parseInt(formData.get('order')),
            classId: null,
            games: editingUnit?.games || []
        };

        try {
            if (editingUnit) {
                await updateDoc(doc(db, 'game_units', editingUnit.id), unitData);
            } else {
                await addDoc(collection(db, 'game_units'), unitData);
            }
            setShowModal(false);
            setEditingUnit(null);
        } catch (error) {
            console.error("Error saving unit: ", error);
        }
    };

    // Media Upload Handler
    const handleFileUpload = async (file, mediaType) => {
        if (!file) return;

        const maxSize = mediaType === 'video' ? 100 * 1024 * 1024 : 10 * 1024 * 1024; // 100MB for video, 10MB for others
        if (file.size > maxSize) {
            alert(`El archivo es muy grande. Máximo ${maxSize / (1024 * 1024)}MB`);
            return;
        }

        setUploading(prev => ({ ...prev, [mediaType]: true }));
        setUploadProgress(prev => ({ ...prev, [mediaType]: 0 }));

        const fileName = `${Date.now()}_${file.name}`;
        const storageRef = ref(storage, `activities/${MEDIA_TYPES[mediaType].folder}/${fileName}`);

        const uploadTask = uploadBytesResumable(storageRef, file);

        uploadTask.on('state_changed',
            (snapshot) => {
                const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                setUploadProgress(prev => ({ ...prev, [mediaType]: progress }));
            },
            (error) => {
                console.error('Upload error:', error);
                setUploading(prev => ({ ...prev, [mediaType]: false }));
                alert('Error al subir el archivo');
            },
            async () => {
                const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);
                setActivityForm(prev => ({
                    ...prev,
                    media: { ...prev.media, [mediaType]: downloadURL }
                }));
                setUploading(prev => ({ ...prev, [mediaType]: false }));
            }
        );
    };

    const handleRemoveMedia = async (mediaType) => {
        const url = activityForm.media[mediaType];
        if (url && url.includes('firebase')) {
            try {
                const fileRef = ref(storage, url);
                await deleteObject(fileRef);
            } catch (err) {
                console.log('Error removing file from storage:', err);
            }
        }
        setActivityForm(prev => ({
            ...prev,
            media: { ...prev.media, [mediaType]: null }
        }));
    };

    // Question Handlers
    const addQuestion = () => {
        setActivityForm(prev => ({
            ...prev,
            questions: [...prev.questions, {
                id: `q_${Date.now()}`,
                text: '',
                imageUrl: null,
                audioUrl: null,
                options: ['', '', '', ''],
                correctIndex: 0,
                explanation: ''
            }]
        }));
    };

    const updateQuestion = (index, field, value) => {
        setActivityForm(prev => {
            const questions = [...prev.questions];
            questions[index] = { ...questions[index], [field]: value };
            return { ...prev, questions };
        });
    };

    const updateQuestionOption = (qIndex, optIndex, value) => {
        setActivityForm(prev => {
            const questions = [...prev.questions];
            const options = [...questions[qIndex].options];
            options[optIndex] = value;
            questions[qIndex] = { ...questions[qIndex], options };
            return { ...prev, questions };
        });
    };

    const removeQuestion = (index) => {
        setActivityForm(prev => ({
            ...prev,
            questions: prev.questions.filter((_, i) => i !== index)
        }));
    };

    const handleQuestionMediaUpload = async (file, questionIndex, mediaType) => {
        if (!file) return;

        const maxSize = 10 * 1024 * 1024;
        if (file.size > maxSize) {
            alert('El archivo es muy grande. Máximo 10MB');
            return;
        }

        const uploadKey = `q_${questionIndex}_${mediaType}`;
        setUploading(prev => ({ ...prev, [uploadKey]: true }));
        setUploadProgress(prev => ({ ...prev, [uploadKey]: 0 }));

        const fileName = `${Date.now()}_${file.name}`;
        const folder = mediaType === 'image' ? 'questions/images' : 'questions/audios';
        const storageRef = ref(storage, `activities/${folder}/${fileName}`);

        const uploadTask = uploadBytesResumable(storageRef, file);

        uploadTask.on('state_changed',
            (snapshot) => {
                const progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                setUploadProgress(prev => ({ ...prev, [uploadKey]: progress }));
            },
            (error) => {
                console.error('Upload error:', error);
                setUploading(prev => ({ ...prev, [uploadKey]: false }));
                alert('Error al subir el archivo');
            },
            async () => {
                const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);
                const field = mediaType === 'image' ? 'imageUrl' : 'audioUrl';
                updateQuestion(questionIndex, field, downloadURL);
                setUploading(prev => ({ ...prev, [uploadKey]: false }));
            }
        );
    };

    // Activity Modal Handlers
    const openActivityModal = (unitId, activity = null, index = null) => {
        setActivityUnitId(unitId);
        setActiveTab('general');
        if (activity) {
            setEditingActivity({ ...activity, index });
            setActivityForm({
                title: activity.title || '',
                subtitle: activity.subtitle || '',
                type: activity.type || 'quiz',
                icon: activity.icon || 'games',
                color: activity.color || 0xFF42A5F5,
                media: activity.media || { image: null, audio: null, video: null },
                questions: activity.questions || [],
                instructions: activity.instructions || ''
            });
        } else {
            setEditingActivity(null);
            setActivityForm({
                title: '',
                subtitle: '',
                type: 'quiz',
                icon: 'games',
                color: 0xFF42A5F5,
                media: { image: null, audio: null, video: null },
                questions: [],
                instructions: ''
            });
        }
        setShowActivityModal(true);
    };

    const handleSaveActivity = async (e) => {
        e.preventDefault();
        const unit = units.find(u => u.id === activityUnitId);
        if (!unit) return;

        const activities = [...(unit.games || [])];
        const activityData = {
            ...activityForm,
            id: editingActivity?.id || `activity_${Date.now()}`
        };

        if (editingActivity !== null && editingActivity.index !== undefined) {
            activities[editingActivity.index] = activityData;
        } else {
            activities.push(activityData);
        }

        try {
            await updateDoc(doc(db, 'game_units', activityUnitId), { games: activities });
            setShowActivityModal(false);
            setEditingActivity(null);
        } catch (error) {
            console.error("Error saving activity:", error);
        }
    };

    const handleDeleteActivity = async (unitId, activityIndex) => {
        if (!window.confirm('¿Eliminar esta actividad?')) return;

        const unit = units.find(u => u.id === unitId);
        if (!unit) return;

        const activities = [...(unit.games || [])];
        activities.splice(activityIndex, 1);

        try {
            await updateDoc(doc(db, 'game_units', unitId), { games: activities });
        } catch (error) {
            console.error("Error deleting activity:", error);
        }
    };

    const getTypeInfo = (type) => ACTIVITY_TYPES.find(t => t.value === type) || ACTIVITY_TYPES[0];

    // Media Preview Component
    const MediaPreview = ({ type, url }) => {
        if (!url) return null;
        switch (type) {
            case 'image':
                return <img src={url} alt="Preview" className="media-preview-image" />;
            case 'audio':
                return <audio controls src={url} className="media-preview-audio" />;
            case 'video':
                return <video controls src={url} className="media-preview-video" />;
            default:
                return null;
        }
    };

    // Upload Zone Component 
    const UploadZone = ({ type, currentUrl, onUpload, onRemove, uploadKey }) => {
        const MediaIcon = MEDIA_TYPES[type].icon;
        const isUploading = uploading[uploadKey || type];
        const progress = uploadProgress[uploadKey || type] || 0;

        return (
            <div className={`upload-zone ${currentUrl ? 'has-media' : ''}`}>
                {isUploading ? (
                    <div className="upload-progress">
                        <Loader2 className="spin" size={24} />
                        <div className="progress-bar">
                            <div className="progress-fill" style={{ width: `${progress}%` }}></div>
                        </div>
                        <span>{Math.round(progress)}%</span>
                    </div>
                ) : currentUrl ? (
                    <div className="media-preview-container">
                        <MediaPreview type={type} url={currentUrl} />
                        <button type="button" className="remove-media-btn" onClick={onRemove}>
                            <X size={16} />
                        </button>
                    </div>
                ) : (
                    <label className="upload-label">
                        <input
                            type="file"
                            accept={MEDIA_TYPES[type].accept}
                            onChange={(e) => onUpload(e.target.files[0])}
                            hidden
                        />
                        <MediaIcon size={32} />
                        <span className="upload-text">Subir {MEDIA_TYPES[type].label}</span>
                        <span className="upload-hint">Arrastra o haz clic</span>
                    </label>
                )}
            </div>
        );
    };

    return (
        <div className="units-page">
            <header className="page-header">
                <div className="header-content">
                    <h1>Unidades Globales</h1>
                    <p>Gestiona las aventuras disponibles para todos los usuarios en el mapa de exploración.</p>
                </div>
                <button className="btn btn-primary" onClick={() => { setEditingUnit(null); setShowModal(true); }}>
                    <Plus size={20} />
                    <span>Nueva Unidad</span>
                </button>
            </header>

            {loading ? (
                <div className="loading-state">Cargando aventuras...</div>
            ) : (
                <div className="units-list">
                    <AnimatePresence>
                        {units.map((unit) => (
                            <motion.div
                                key={unit.id}
                                layout
                                initial={{ opacity: 0, scale: 0.95 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0, scale: 0.95 }}
                                className="card unit-card"
                            >
                                {/* Unit Header */}
                                <div className="unit-header" onClick={() => setExpandedUnit(expandedUnit === unit.id ? null : unit.id)}>
                                    <div className="unit-icon-wrapper" style={{ backgroundColor: `${unit.color || '#42a5f5'}20` }}>
                                        <Gamepad2 size={24} style={{ color: unit.color || '#42a5f5' }} />
                                    </div>
                                    <div className="unit-details">
                                        <h3>{unit.title}</h3>
                                        <p className="subtitle">{unit.subtitle}</p>
                                        <div className="unit-badges">
                                            <span className="badge"><Layers size={14} /> {unit.games?.length || 0} Actividades</span>
                                            <span className="badge"><MapPin size={14} /> Orden: {unit.order}</span>
                                        </div>
                                    </div>
                                    <div className="unit-actions">
                                        <button className="action-btn edit" onClick={(e) => { e.stopPropagation(); setEditingUnit(unit); setShowModal(true); }}>
                                            <Edit2 size={18} />
                                        </button>
                                        <button className="action-btn delete" onClick={(e) => { e.stopPropagation(); handleDelete(unit.id); }}>
                                            <Trash2 size={18} />
                                        </button>
                                        <button className="action-btn expand">
                                            {expandedUnit === unit.id ? <ChevronUp size={20} /> : <ChevronDown size={20} />}
                                        </button>
                                    </div>
                                </div>

                                {/* Expanded Activities */}
                                <AnimatePresence>
                                    {expandedUnit === unit.id && (
                                        <motion.div
                                            initial={{ height: 0, opacity: 0 }}
                                            animate={{ height: 'auto', opacity: 1 }}
                                            exit={{ height: 0, opacity: 0 }}
                                            className="unit-activities"
                                        >
                                            <div className="activities-header">
                                                <h4>Actividades de la Unidad</h4>
                                                <button className="btn btn-small" onClick={() => openActivityModal(unit.id)}>
                                                    <Plus size={16} />
                                                    <span>Añadir</span>
                                                </button>
                                            </div>

                                            {unit.games && unit.games.length > 0 ? (
                                                <div className="activities-list">
                                                    {unit.games.map((activity, index) => {
                                                        const typeInfo = getTypeInfo(activity.type);
                                                        const hasMedia = activity.media && (activity.media.image || activity.media.audio || activity.media.video);
                                                        const hasQuestions = activity.questions && activity.questions.length > 0;
                                                        return (
                                                            <div key={activity.id || index} className="activity-item">
                                                                <div className="activity-number">{index + 1}</div>
                                                                <div className="activity-type-icon" style={{ backgroundColor: `${typeInfo.color}20`, color: typeInfo.color }}>
                                                                    {typeInfo.label.split(' ')[0]}
                                                                </div>
                                                                <div className="activity-info">
                                                                    <span className="activity-title">{activity.title}</span>
                                                                    <span className="activity-type">{typeInfo.label}</span>
                                                                    <div className="activity-meta">
                                                                        {hasMedia && (
                                                                            <span className="meta-badge media">
                                                                                {activity.media.image && <Image size={12} />}
                                                                                {activity.media.audio && <Music size={12} />}
                                                                                {activity.media.video && <Video size={12} />}
                                                                            </span>
                                                                        )}
                                                                        {hasQuestions && (
                                                                            <span className="meta-badge questions">
                                                                                <FileQuestion size={12} />
                                                                                {activity.questions.length}
                                                                            </span>
                                                                        )}
                                                                    </div>
                                                                </div>
                                                                <div className="activity-actions">
                                                                    <button className="icon-btn" onClick={() => openActivityModal(unit.id, activity, index)}>
                                                                        <Edit2 size={14} />
                                                                    </button>
                                                                    <button className="icon-btn delete" onClick={() => handleDeleteActivity(unit.id, index)}>
                                                                        <Trash2 size={14} />
                                                                    </button>
                                                                </div>
                                                            </div>
                                                        );
                                                    })}
                                                </div>
                                            ) : (
                                                <div className="empty-activities">
                                                    <Play size={32} />
                                                    <p>Sin actividades aún</p>
                                                    <span>Añade juegos para que los jugadores completen</span>
                                                </div>
                                            )}
                                        </motion.div>
                                    )}
                                </AnimatePresence>
                            </motion.div>
                        ))}
                    </AnimatePresence>

                    {units.length === 0 && (
                        <div className="empty-state">
                            <Gamepad2 size={64} />
                            <h3>No hay unidades globales</h3>
                            <p>Crea la primera unidad para el mapa de exploración</p>
                        </div>
                    )}
                </div>
            )}

            {/* Unit Modal */}
            <AnimatePresence>
                {showModal && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="modal-overlay"
                        onClick={() => setShowModal(false)}
                    >
                        <motion.div
                            initial={{ y: 50, opacity: 0 }}
                            animate={{ y: 0, opacity: 1 }}
                            exit={{ y: 50, opacity: 0 }}
                            className="card modal-content"
                            onClick={e => e.stopPropagation()}
                        >
                            <div className="modal-header">
                                <h2>{editingUnit ? 'Editar Unidad' : 'Nueva Unidad Global'}</h2>
                                <p>Configura los detalles de la aventura educativa.</p>
                            </div>

                            <form onSubmit={handleSubmit} className="unit-form">
                                <div className="form-group">
                                    <label>Título de la Unidad</label>
                                    <input
                                        name="title"
                                        defaultValue={editingUnit?.title}
                                        required
                                        placeholder="Ej: Aventura Espacial"
                                    />
                                </div>
                                <div className="form-group">
                                    <label>Subtítulo / Descripción Corta</label>
                                    <input
                                        name="subtitle"
                                        defaultValue={editingUnit?.subtitle}
                                        required
                                        placeholder="Ej: Aprende sobre los planetas"
                                    />
                                </div>
                                <div className="form-row">
                                    <div className="form-group">
                                        <label>Color Temático</label>
                                        <input
                                            name="color"
                                            type="color"
                                            defaultValue={editingUnit?.color || '#42a5f5'}
                                            required
                                        />
                                    </div>
                                    <div className="form-group">
                                        <label>Orden en el Mapa</label>
                                        <input
                                            name="order"
                                            type="number"
                                            defaultValue={editingUnit?.order || units.length + 1}
                                            required
                                        />
                                    </div>
                                </div>

                                <div className="modal-footer">
                                    <button type="button" className="btn" onClick={() => setShowModal(false)}>Cancelar</button>
                                    <button type="submit" className="btn btn-primary">
                                        {editingUnit ? 'Guardar Cambios' : 'Crear Unidad'}
                                    </button>
                                </div>
                            </form>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>

            {/* Activity Modal - Enhanced */}
            <AnimatePresence>
                {showActivityModal && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="modal-overlay"
                        onClick={() => setShowActivityModal(false)}
                    >
                        <motion.div
                            initial={{ y: 50, opacity: 0 }}
                            animate={{ y: 0, opacity: 1 }}
                            exit={{ y: 50, opacity: 0 }}
                            className="card modal-content modal-large"
                            onClick={e => e.stopPropagation()}
                        >
                            <div className="modal-header">
                                <h2>{editingActivity ? 'Editar Actividad' : 'Nueva Actividad'}</h2>
                                <p>Configura el juego o desafío para los jugadores.</p>
                            </div>

                            {/* Tabs  */}
                            <div className="modal-tabs">
                                <button
                                    type="button"
                                    className={`tab ${activeTab === 'general' ? 'active' : ''}`}
                                    onClick={() => setActiveTab('general')}
                                >
                                    <Gamepad2 size={16} />
                                    General
                                </button>
                                <button
                                    type="button"
                                    className={`tab ${activeTab === 'media' ? 'active' : ''}`}
                                    onClick={() => setActiveTab('media')}
                                >
                                    <Image size={16} />
                                    Multimedia
                                </button>
                                <button
                                    type="button"
                                    className={`tab ${activeTab === 'questions' ? 'active' : ''}`}
                                    onClick={() => setActiveTab('questions')}
                                >
                                    <FileQuestion size={16} />
                                    Preguntas
                                    {activityForm.questions.length > 0 && (
                                        <span className="tab-badge">{activityForm.questions.length}</span>
                                    )}
                                </button>
                            </div>

                            <form onSubmit={handleSaveActivity} className="activity-form">
                                {/* General Tab */}
                                {activeTab === 'general' && (
                                    <div className="tab-content">
                                        <div className="form-group">
                                            <label>Título de la Actividad</label>
                                            <input
                                                type="text"
                                                value={activityForm.title}
                                                onChange={(e) => setActivityForm({ ...activityForm, title: e.target.value })}
                                                required
                                                placeholder="Ej: Quiz sobre planetas"
                                            />
                                        </div>

                                        <div className="form-group">
                                            <label>Instrucciones de la Actividad</label>
                                            <textarea
                                                value={activityForm.instructions}
                                                onChange={(e) => setActivityForm({ ...activityForm, instructions: e.target.value })}
                                                placeholder="Escribe aquí las instrucciones detalladas para el estudiante..."
                                                rows={3}
                                            />
                                        </div>

                                        <div className="form-group">
                                            <label>Subtítulo (opcional)</label>
                                            <input
                                                type="text"
                                                value={activityForm.subtitle}
                                                onChange={(e) => setActivityForm({ ...activityForm, subtitle: e.target.value })}
                                                placeholder="Ej: Demuestra lo que sabes"
                                            />
                                        </div>

                                        <div className="form-group">
                                            <label>Tipo de Juego</label>
                                            <div className="type-selector">
                                                {ACTIVITY_TYPES.map(type => (
                                                    <button
                                                        key={type.value}
                                                        type="button"
                                                        className={`type-option ${activityForm.type === type.value ? 'selected' : ''}`}
                                                        style={{ '--type-color': type.color }}
                                                        onClick={() => setActivityForm({ ...activityForm, type: type.value })}
                                                    >
                                                        <span className="type-emoji">{type.label.split(' ')[0]}</span>
                                                        <span className="type-name">{type.label.split(' ').slice(1).join(' ')}</span>
                                                        <span className="type-desc">{type.description}</span>
                                                    </button>
                                                ))}
                                            </div>
                                        </div>
                                    </div>
                                )}

                                {/* Media Tab */}
                                {activeTab === 'media' && (
                                    <div className="tab-content">
                                        <div className="media-info-banner">
                                            <AlertCircle size={18} />
                                            <span>Añade contenido multimedia para hacer la actividad más interactiva y atractiva.</span>
                                        </div>

                                        <div className="media-upload-grid">
                                            <div className="media-upload-section">
                                                <h4><Image size={18} /> Imagen Principal</h4>
                                                <p className="section-hint">Imagen que se mostrará como portada de la actividad</p>
                                                <UploadZone
                                                    type="image"
                                                    currentUrl={activityForm.media.image}
                                                    onUpload={(file) => handleFileUpload(file, 'image')}
                                                    onRemove={() => handleRemoveMedia('image')}
                                                />
                                            </div>

                                            <div className="media-upload-section">
                                                <h4><Music size={18} /> Audio / Narración</h4>
                                                <p className="section-hint">Audio que acompañará la actividad o instrucciones</p>
                                                <UploadZone
                                                    type="audio"
                                                    currentUrl={activityForm.media.audio}
                                                    onUpload={(file) => handleFileUpload(file, 'audio')}
                                                    onRemove={() => handleRemoveMedia('audio')}
                                                />
                                            </div>

                                            <div className="media-upload-section full-width">
                                                <h4><Video size={18} /> Video Introductorio</h4>
                                                <p className="section-hint">Video explicativo o introductorio para la actividad (máx. 100MB)</p>
                                                <UploadZone
                                                    type="video"
                                                    currentUrl={activityForm.media.video}
                                                    onUpload={(file) => handleFileUpload(file, 'video')}
                                                    onRemove={() => handleRemoveMedia('video')}
                                                />
                                            </div>
                                        </div>
                                    </div>
                                )}

                                {/* Questions Tab */}
                                {activeTab === 'questions' && (
                                    <div className="tab-content">
                                        <div className="questions-header">
                                            <div>
                                                <h4>Preguntas del Quiz</h4>
                                                <p>Añade las preguntas y respuestas para esta actividad</p>
                                            </div>
                                            <button type="button" className="btn btn-small" onClick={addQuestion}>
                                                <Plus size={16} />
                                                Añadir Pregunta
                                            </button>
                                        </div>

                                        {activityForm.questions.length === 0 ? (
                                            <div className="empty-questions">
                                                <FileQuestion size={48} />
                                                <p>No hay preguntas aún</p>
                                                <span>Haz clic en "Añadir Pregunta" para comenzar</span>
                                            </div>
                                        ) : (
                                            <div className="questions-list">
                                                {activityForm.questions.map((question, qIndex) => (
                                                    <div key={question.id} className="question-card">
                                                        <div className="question-header">
                                                            <span className="question-number">Pregunta {qIndex + 1}</span>
                                                            <button
                                                                type="button"
                                                                className="icon-btn delete"
                                                                onClick={() => removeQuestion(qIndex)}
                                                            >
                                                                <Trash2 size={14} />
                                                            </button>
                                                        </div>

                                                        <div className="question-content">
                                                            <div className="form-group">
                                                                <label>Texto de la pregunta</label>
                                                                <textarea
                                                                    value={question.text}
                                                                    onChange={(e) => updateQuestion(qIndex, 'text', e.target.value)}
                                                                    placeholder="Escribe aquí tu pregunta..."
                                                                    rows={2}
                                                                />
                                                            </div>

                                                            <div className="question-media-row">
                                                                <div className="mini-upload">
                                                                    <label>Imagen (opcional)</label>
                                                                    {question.imageUrl ? (
                                                                        <div className="mini-preview">
                                                                            <img src={question.imageUrl} alt="" />
                                                                            <button
                                                                                type="button"
                                                                                onClick={() => updateQuestion(qIndex, 'imageUrl', null)}
                                                                            >
                                                                                <X size={12} />
                                                                            </button>
                                                                        </div>
                                                                    ) : uploading[`q_${qIndex}_image`] ? (
                                                                        <div className="mini-uploading">
                                                                            <Loader2 className="spin" size={16} />
                                                                            <span>{Math.round(uploadProgress[`q_${qIndex}_image`] || 0)}%</span>
                                                                        </div>
                                                                    ) : (
                                                                        <label className="mini-upload-btn">
                                                                            <input
                                                                                type="file"
                                                                                accept="image/*"
                                                                                onChange={(e) => handleQuestionMediaUpload(e.target.files[0], qIndex, 'image')}
                                                                                hidden
                                                                            />
                                                                            <Image size={14} />
                                                                            <span>Subir</span>
                                                                        </label>
                                                                    )}
                                                                </div>

                                                                <div className="mini-upload">
                                                                    <label>Audio (opcional)</label>
                                                                    {question.audioUrl ? (
                                                                        <div className="mini-preview audio">
                                                                            <audio controls src={question.audioUrl} />
                                                                            <button
                                                                                type="button"
                                                                                onClick={() => updateQuestion(qIndex, 'audioUrl', null)}
                                                                            >
                                                                                <X size={12} />
                                                                            </button>
                                                                        </div>
                                                                    ) : uploading[`q_${qIndex}_audio`] ? (
                                                                        <div className="mini-uploading">
                                                                            <Loader2 className="spin" size={16} />
                                                                            <span>{Math.round(uploadProgress[`q_${qIndex}_audio`] || 0)}%</span>
                                                                        </div>
                                                                    ) : (
                                                                        <label className="mini-upload-btn">
                                                                            <input
                                                                                type="file"
                                                                                accept="audio/*"
                                                                                onChange={(e) => handleQuestionMediaUpload(e.target.files[0], qIndex, 'audio')}
                                                                                hidden
                                                                            />
                                                                            <Music size={14} />
                                                                            <span>Subir</span>
                                                                        </label>
                                                                    )}
                                                                </div>
                                                            </div>

                                                            <div className="form-group">
                                                                <label>Opciones de respuesta</label>
                                                                <div className="options-grid">
                                                                    {question.options.map((option, oIndex) => (
                                                                        <div
                                                                            key={oIndex}
                                                                            className={`option-input ${question.correctIndex === oIndex ? 'correct' : ''}`}
                                                                        >
                                                                            <button
                                                                                type="button"
                                                                                className="correct-toggle"
                                                                                onClick={() => updateQuestion(qIndex, 'correctIndex', oIndex)}
                                                                                title={question.correctIndex === oIndex ? 'Respuesta correcta' : 'Marcar como correcta'}
                                                                            >
                                                                                {question.correctIndex === oIndex ? <Check size={14} /> : <span>{oIndex + 1}</span>}
                                                                            </button>
                                                                            <input
                                                                                type="text"
                                                                                value={option}
                                                                                onChange={(e) => updateQuestionOption(qIndex, oIndex, e.target.value)}
                                                                                placeholder={`Opción ${oIndex + 1}`}
                                                                            />
                                                                        </div>
                                                                    ))}
                                                                </div>
                                                                <p className="options-hint">
                                                                    <Check size={12} /> Haz clic en el número para marcar la respuesta correcta
                                                                </p>
                                                            </div>

                                                            <div className="form-group">
                                                                <label>Explicación (opcional)</label>
                                                                <textarea
                                                                    value={question.explanation}
                                                                    onChange={(e) => updateQuestion(qIndex, 'explanation', e.target.value)}
                                                                    placeholder="Explicación que se mostrará después de responder..."
                                                                    rows={2}
                                                                />
                                                            </div>
                                                        </div>
                                                    </div>
                                                ))}
                                            </div>
                                        )}
                                    </div>
                                )}

                                <div className="modal-footer">
                                    <button type="button" className="btn" onClick={() => setShowActivityModal(false)}>Cancelar</button>
                                    <button type="submit" className="btn btn-primary">
                                        {editingActivity ? 'Actualizar Actividad' : 'Crear Actividad'}
                                    </button>
                                </div>
                            </form>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default UnitsPage;
