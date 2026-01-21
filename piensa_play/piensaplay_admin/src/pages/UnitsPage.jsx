import React, { useState, useEffect, useRef } from 'react';
import { db } from '../firebase';
import { collection, query, where, onSnapshot, addDoc, updateDoc, doc, deleteDoc } from 'firebase/firestore';
import { uploadToCloudinary } from '../cloudinary';
import {
    Gamepad2, Plus, Edit2, Trash2, MapPin, Layers,
    ChevronDown, ChevronUp, Play, Image, Music, Video,
    Upload, X, Check, AlertCircle, Loader2, Eye, FileQuestion, Info, ArrowLeft, ArrowRight
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import { getQuestionForm, getDefaultQuestion, validateQuestions, getAddButtonLabel, getMinQuestions } from '../components/QuestionForms';
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
    const [activeStep, setActiveStep] = useState(1);
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

        const maxSize = mediaType === 'video' ? 100 * 1024 * 1024 : 10 * 1024 * 1024;
        if (file.size > maxSize) {
            alert(`El archivo es muy grande. Máximo ${maxSize / (1024 * 1024)}MB`);
            return;
        }

        try {
            setUploading(prev => ({ ...prev, [mediaType]: true }));
            setUploadProgress(prev => ({ ...prev, [mediaType]: 5 }));

            const result = await uploadToCloudinary(file, (progress) => {
                setUploadProgress(prev => ({ ...prev, [mediaType]: progress }));
            });

            setActivityForm(prev => ({
                ...prev,
                media: { ...prev.media, [mediaType]: result.url }
            }));

            setUploadProgress(prev => ({ ...prev, [mediaType]: 100 }));
            setUploading(prev => ({ ...prev, [mediaType]: false }));
        } catch (error) {
            console.error('Cloudinary Upload error:', error);
            setUploading(prev => ({ ...prev, [mediaType]: false }));
            alert(`Error al subir: ${error.message}`);
        }
    };

    const handleRemoveMedia = async (mediaType) => {
        // Con Cloudinary, la eliminación requiere backend
        // Por ahora solo limpiamos la URL del formulario
        setActivityForm(prev => ({
            ...prev,
            media: { ...prev.media, [mediaType]: null }
        }));
    };

    // Question Handlers
    const addQuestion = () => {
        const newQuestion = getDefaultQuestion(activityForm.type);
        setActivityForm(prev => ({
            ...prev,
            questions: [
                ...prev.questions,
                newQuestion
            ]
        }));
    };

    // Get validation status for current activity
    const getValidationStatus = () => {
        const minQuestions = getMinQuestions(activityForm.type);
        if (activityForm.questions.length < minQuestions) {
            return { valid: false, message: `Se requieren al menos ${minQuestions} ${minQuestions === 1 ? 'pregunta' : 'preguntas'}` };
        }
        return validateQuestions(activityForm.type, activityForm.questions);
    };

    const canSaveActivity = () => {
        if (!activityForm.title.trim()) return false;
        const validation = getValidationStatus();
        return validation.valid;
    };

    const updateQuestion = (index, field, value) => {
        setActivityForm(prev => {
            const questions = [...prev.questions];
            questions[index] = { ...questions[index], [field]: value };
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
        try {
            setUploading(prev => ({ ...prev, [uploadKey]: true }));
            setUploadProgress(prev => ({ ...prev, [uploadKey]: 5 }));

            const result = await uploadToCloudinary(file, (progress) => {
                setUploadProgress(prev => ({ ...prev, [uploadKey]: progress }));
            });

            const downloadURL = result.url;
            const newQuestions = [...activityForm.questions];
            const q = { ...newQuestions[questionIndex] };

            if (mediaType === 'cardA_image') q.cardA = { ...q.cardA, image: downloadURL };
            else if (mediaType === 'cardB_image') q.cardB = { ...q.cardB, image: downloadURL };
            else if (mediaType.includes('Image')) q[mediaType] = downloadURL;
            else if (mediaType === 'image') q.imageUrl = downloadURL;
            else if (mediaType === 'audio') q.audioUrl = downloadURL;
            else q[mediaType] = downloadURL;

            newQuestions[questionIndex] = q;
            setActivityForm(prev => ({ ...prev, questions: newQuestions }));
            setUploadProgress(prev => ({ ...prev, [uploadKey]: 100 }));
            setUploading(prev => ({ ...prev, [uploadKey]: false }));
        } catch (error) {
            console.error('Question Upload error:', error);
            setUploading(prev => ({ ...prev, [uploadKey]: false }));
            alert(`Error en pregunta: ${error.message}`);
        }
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
            setActiveStep(2); // Start at details if editing
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
            setActiveStep(1); // Start at type selection if new
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
        const key = uploadKey || type;
        const isUploading = uploading[key];
        const progress = uploadProgress[key] || 0;

        return (
            <div className={`upload-zone ${currentUrl ? 'has-media' : ''} ${isUploading ? 'uploading' : ''}`}>
                {isUploading ? (
                    <div className="upload-progress-v2">
                        <div className="progress-ring-container">
                            <Loader2 className="spin" size={32} />
                            <span className="progress-number">{progress}%</span>
                        </div>
                        <div className="progress-bar-v2">
                            <div className="progress-fill-v2" style={{ width: `${progress}%` }}></div>
                        </div>
                        <span className="upload-status">Subiendo {MEDIA_TYPES[type].label}...</span>
                    </div>
                ) : currentUrl ? (
                    <div className="media-preview-container-v2">
                        <MediaPreview type={type} url={currentUrl} />
                        <div className="media-overlay-actions">
                            <button type="button" className="action-btn-mini remove" onClick={onRemove} title="Eliminar">
                                <X size={14} />
                            </button>
                            <label className="action-btn-mini change" title="Cambiar">
                                <input
                                    type="file"
                                    accept={MEDIA_TYPES[type].accept}
                                    onChange={(e) => onUpload(e.target.files[0])}
                                    hidden
                                />
                                <Upload size={14} />
                            </label>
                        </div>
                    </div>
                ) : (
                    <label className="upload-label-v2">
                        <input
                            type="file"
                            accept={MEDIA_TYPES[type].accept}
                            onChange={(e) => onUpload(e.target.files[0])}
                            hidden
                        />
                        <div className="upload-icon-wrapper">
                            <MediaIcon size={28} />
                            <div className="plus-badge"><Plus size={10} /></div>
                        </div>
                        <span className="upload-text-v2">Subir {MEDIA_TYPES[type].label}</span>
                        <span className="upload-hint-v2">PNG, JPG o MP3 hasta 10MB</span>
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
                            className="card modal-content modal-large activity-modal-v3"
                            onClick={e => e.stopPropagation()}
                        >
                            <div className="modal-header">
                                <h2>{editingActivity ? 'Editar Actividad' : 'Nueva Actividad'}</h2>
                                <p>Configura el juego o desafío para los jugadores.</p>
                            </div>

                            {/* Stepper Header */}
                            <div className="modal-stepper">
                                <div className={`step-item ${activeStep >= 1 ? 'active' : ''} ${activeStep > 1 ? 'completed' : ''}`}>
                                    <div className="step-number">{activeStep > 1 ? <Check size={16} /> : '1'}</div>
                                    <span className="step-label">Tipo</span>
                                </div>
                                <div className="step-divider"></div>
                                <div className={`step-item ${activeStep >= 2 ? 'active' : ''} ${activeStep > 2 ? 'completed' : ''}`}>
                                    <div className="step-number">{activeStep > 2 ? <Check size={16} /> : '2'}</div>
                                    <span className="step-label">Detalles</span>
                                </div>
                                <div className="step-divider"></div>
                                <div className={`step-item ${activeStep >= 3 ? 'active' : ''}`}>
                                    <div className="step-number">3</div>
                                    <span className="step-label">Contenido</span>
                                </div>
                            </div>

                            <form onSubmit={handleSaveActivity} className="activity-form">
                                {/* Step 1: Select Type */}
                                {activeStep === 1 && (
                                    <div className="tab-content step-fade">
                                        <div className="step-header">
                                            <h3>Selecciona el Tipo de Juego</h3>
                                            <p>Elige la mecánica que mejor se adapte a tu objetivo educativo.</p>
                                        </div>
                                        <div className="type-selector-grid">
                                            {ACTIVITY_TYPES.map(type => (
                                                <button
                                                    key={type.value}
                                                    type="button"
                                                    className={`type-card ${activityForm.type === type.value ? 'selected' : ''}`}
                                                    onClick={() => {
                                                        setActivityForm({ ...activityForm, type: type.value });
                                                        setActiveStep(2);
                                                    }}
                                                >
                                                    <div className="type-icon-circle" style={{ backgroundColor: `${type.color}20`, color: type.color }}>
                                                        <span className="type-emoji-large">{type.label.split(' ')[0]}</span>
                                                    </div>
                                                    <div className="type-card-body">
                                                        <span className="type-name">{type.label.split(' ').slice(1).join(' ')}</span>
                                                        <span className="type-desc">{type.description}</span>
                                                    </div>
                                                </button>
                                            ))}
                                        </div>
                                    </div>
                                )}

                                {/* Step 2: Basic Info & Media */}
                                {activeStep === 2 && (
                                    <div className="tab-content step-fade">
                                        <div className="step-header">
                                            <h3>Detalles de la Actividad</h3>
                                            <p>Nombre, instrucciones y recursos visuales del juego.</p>
                                        </div>

                                        <div className="form-split">
                                            <div className="form-column">
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
                                                    <label>Instrucciones</label>
                                                    <textarea
                                                        value={activityForm.instructions}
                                                        onChange={(e) => setActivityForm({ ...activityForm, instructions: e.target.value })}
                                                        placeholder="Instrucciones para el estudiante..."
                                                        rows={4}
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
                                            </div>

                                            <div className="form-column">
                                                <div className="media-section">
                                                    <label>Portada e Iconos</label>
                                                    <div className="mini-media-grid">
                                                        <div className="mini-upload">
                                                            <span>Imagen</span>
                                                            <UploadZone
                                                                type="image"
                                                                currentUrl={activityForm.media.image}
                                                                onUpload={(file) => handleFileUpload(file, 'image')}
                                                                onRemove={() => handleRemoveMedia('image')}
                                                            />
                                                        </div>
                                                        <div className="mini-upload">
                                                            <span>Audio</span>
                                                            <UploadZone
                                                                type="audio"
                                                                currentUrl={activityForm.media.audio}
                                                                onUpload={(file) => handleFileUpload(file, 'audio')}
                                                                onRemove={() => handleRemoveMedia('audio')}
                                                            />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                )}

                                {/* Step 3: Game Content - REDESIGNED */}
                                {activeStep === 3 && (
                                    <div className="tab-content step-fade">
                                        {(() => {
                                            const typeInfo = getTypeInfo(activityForm.type);
                                            const minQuestions = getMinQuestions(activityForm.type);
                                            const validation = getValidationStatus();
                                            const QuestionFormComponent = getQuestionForm(activityForm.type);
                                            const currentCount = activityForm.questions.length;

                                            return (
                                                <div className="content-step-wrapper">
                                                    {/* Left Panel - Help & Progress */}
                                                    <div className="content-sidebar">
                                                        <div className="sidebar-section">
                                                            <div className="game-type-badge" style={{ backgroundColor: `${typeInfo.color}20`, borderColor: typeInfo.color }}>
                                                                <span className="badge-emoji">{typeInfo.label.split(' ')[0]}</span>
                                                                <span className="badge-text">{typeInfo.label.split(' ').slice(1).join(' ')}</span>
                                                            </div>
                                                            <p className="type-description">{typeInfo.description}</p>
                                                        </div>

                                                        <div className="sidebar-section progress-section">
                                                            <h4>📊 Progreso</h4>
                                                            <div className="progress-ring-wrapper">
                                                                <div className="progress-ring" style={{
                                                                    '--progress': `${Math.min((currentCount / minQuestions) * 100, 100)}%`,
                                                                    '--color': validation.valid ? '#10b981' : typeInfo.color
                                                                }}>
                                                                    <span className="progress-count">{currentCount}</span>
                                                                    <span className="progress-label">/ {minQuestions} mín.</span>
                                                                </div>
                                                            </div>
                                                            <div className={`status-badge ${validation.valid ? 'ready' : 'pending'}`}>
                                                                {validation.valid ? (
                                                                    <><Check size={14} /> Listo para guardar</>
                                                                ) : (
                                                                    <><AlertCircle size={14} /> {validation.message}</>
                                                                )}
                                                            </div>
                                                        </div>

                                                        <div className="sidebar-section tips-section">
                                                            <h4>💡 Tips</h4>
                                                            <ul className="tips-list">
                                                                <li>Añade al menos {minQuestions} elementos</li>
                                                                <li>Las imágenes hacen el juego más atractivo</li>
                                                                <li>Puedes reordenar arrastrando</li>
                                                            </ul>
                                                        </div>
                                                    </div>

                                                    {/* Right Panel - Content Editor */}
                                                    <div className="content-editor-panel">
                                                        <div className="editor-header">
                                                            <h3>Contenido del Juego</h3>
                                                            <button type="button" className="btn btn-primary" onClick={addQuestion}>
                                                                <Plus size={16} />
                                                                {getAddButtonLabel(activityForm.type)}
                                                            </button>
                                                        </div>

                                                        <div className="editor-scroll-area">
                                                            {activityForm.questions.length === 0 ? (
                                                                <div className="empty-content-state">
                                                                    <div className="empty-illustration">
                                                                        <div className="empty-icon-circle" style={{ backgroundColor: `${typeInfo.color}20` }}>
                                                                            <Plus size={40} strokeWidth={1.5} style={{ color: typeInfo.color }} />
                                                                        </div>
                                                                    </div>
                                                                    <h4>Empieza a crear</h4>
                                                                    <p>Añade {getAddButtonLabel(activityForm.type).toLowerCase()} para que los jugadores puedan interactuar con tu actividad.</p>
                                                                    <button type="button" className="btn btn-primary btn-large" onClick={addQuestion}>
                                                                        <Plus size={18} />
                                                                        Añadir primer elemento
                                                                    </button>
                                                                </div>
                                                            ) : (
                                                                <div className="questions-grid">
                                                                    {activityForm.questions.map((question, qIndex) => (
                                                                        <QuestionFormComponent
                                                                            key={question.id || qIndex}
                                                                            question={question}
                                                                            index={qIndex}
                                                                            onUpdate={(field, value) => updateQuestion(qIndex, field, value)}
                                                                            onDelete={() => removeQuestion(qIndex)}
                                                                            onMediaUpload={(file, type) => handleQuestionMediaUpload(file, qIndex, type)}
                                                                            uploading={uploading}
                                                                            uploadProgress={uploadProgress}
                                                                        />
                                                                    ))}
                                                                </div>
                                                            )}
                                                        </div>
                                                    </div>
                                                </div>
                                            );
                                        })()}
                                    </div>
                                )}

                                <div className="modal-footer-stepper">
                                    {activeStep > 1 && (
                                        <button type="button" className="btn btn-secondary" onClick={() => setActiveStep(activeStep - 1)}>
                                            <ArrowLeft size={18} /> Anterior
                                        </button>
                                    )}

                                    <div className="footer-spacer"></div>

                                    <button type="button" className="btn btn-ghost" onClick={() => setShowActivityModal(false)}>
                                        Cancelar
                                    </button>

                                    {activeStep < 3 ? (
                                        <button
                                            type="button"
                                            className="btn btn-primary"
                                            onClick={() => setActiveStep(activeStep + 1)}
                                            disabled={activeStep === 2 && !activityForm.title}
                                        >
                                            Siguiente <ArrowRight size={18} />
                                        </button>
                                    ) : (
                                        <button
                                            type="submit"
                                            className="btn btn-accent"
                                            disabled={!canSaveActivity()}
                                        >
                                            {editingActivity ? 'Guardar Cambios' : 'Finalizar y Crear'}
                                        </button>
                                    )}
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
