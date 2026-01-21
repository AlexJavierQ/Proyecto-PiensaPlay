import React, { useState, useEffect, useRef } from 'react';
import { db } from '../firebase';
import { doc, getDoc, setDoc, collection, getDocs, addDoc, deleteDoc, updateDoc } from 'firebase/firestore';
import { uploadToCloudinary } from '../cloudinary';
import {
    Settings, Save, Palette, UserCircle, Shield,
    Plus, Trash2, Edit2, Image, Coins, Star, Upload, X, Loader2,
    Zap, Award, BookOpen, ShoppingBag, Lock
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import './SettingsPage.css';

const SettingsPage = () => {
    const [activeTab, setActiveTab] = useState('avatars');
    const [loading, setLoading] = useState(false);
    const [saving, setSaving] = useState(false);

    // Default Avatars State
    const [defaultAvatars, setDefaultAvatars] = useState([]);
    const [showAvatarModal, setShowAvatarModal] = useState(false);
    const [editingAvatar, setEditingAvatar] = useState(null);
    const [uploading, setUploading] = useState(false);
    const [uploadProgress, setUploadProgress] = useState(0);
    const fileInputRef = useRef(null);

    const [avatarForm, setAvatarForm] = useState({
        name: '',
        color: '#6366f1',
        imageUrl: '',
        isDefault: true
    });

    // App Config State
    const [appConfig, setAppConfig] = useState({
        initialWalletBalance: 100,
        xpPerActivity: 50,
        coinsPerActivity: 10,
        enableShop: true,
        enableGlossary: true,
        maintenanceMode: false
    });

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        setLoading(true);
        try {
            // Fetch default avatars
            const avatarsSnap = await getDocs(collection(db, 'default_avatars'));
            setDefaultAvatars(avatarsSnap.docs.map(d => ({ id: d.id, ...d.data() })));

            // Fetch app config
            const configDoc = await getDoc(doc(db, 'app_config', 'general'));
            if (configDoc.exists()) {
                setAppConfig({ ...appConfig, ...configDoc.data() });
            }
        } catch (error) {
            console.error("Error fetching settings:", error);
        } finally {
            setLoading(false);
        }
    };

    const saveAppConfig = async () => {
        setSaving(true);
        try {
            await setDoc(doc(db, 'app_config', 'general'), appConfig);
            alert('Configuración guardada correctamente');
        } catch (error) {
            console.error("Error saving config:", error);
            alert('Error al guardar: ' + error.message);
        } finally {
            setSaving(false);
        }
    };

    const handleImageUpload = async (file) => {
        if (!file) return;

        const maxSize = 5 * 1024 * 1024;
        if (file.size > maxSize) {
            alert('La imagen es muy grande. Máximo 5MB.');
            return;
        }

        setUploading(true);
        setUploadProgress(5);

        try {
            const result = await uploadToCloudinary(file, (progress) => {
                setUploadProgress(progress);
            });
            setAvatarForm(prev => ({ ...prev, imageUrl: result.url }));
            setUploading(false);
        } catch (error) {
            console.error('Cloudinary Upload error:', error);
            setUploading(false);
            alert('Error al subir la imagen: ' + error.message);
        }
    };

    const handleSaveAvatar = async (e) => {
        e.preventDefault();

        if (!avatarForm.imageUrl) {
            alert('Por favor sube una imagen para el avatar');
            return;
        }

        try {
            if (editingAvatar) {
                await updateDoc(doc(db, 'default_avatars', editingAvatar.id), avatarForm);
            } else {
                await addDoc(collection(db, 'default_avatars'), avatarForm);
            }
            setShowAvatarModal(false);
            setEditingAvatar(null);
            setAvatarForm({ name: '', color: '#6366f1', imageUrl: '', isDefault: true });
            fetchData();
        } catch (error) {
            console.error("Error saving avatar:", error);
        }
    };

    const handleDeleteAvatar = async (id) => {
        if (window.confirm('¿Eliminar este avatar por defecto?')) {
            await deleteDoc(doc(db, 'default_avatars', id));
            fetchData();
        }
    };

    const openNewAvatarModal = () => {
        setEditingAvatar(null);
        setAvatarForm({ name: '', color: '#6366f1', imageUrl: '', isDefault: true });
        setShowAvatarModal(true);
    };

    const openEditAvatarModal = (avatar) => {
        setEditingAvatar(avatar);
        setAvatarForm({
            name: avatar.name || '',
            color: avatar.color || '#6366f1',
            imageUrl: avatar.imageUrl || '',
            isDefault: true
        });
        setShowAvatarModal(true);
    };

    const tabs = [
        { id: 'avatars', label: 'Avatares Iniciales', icon: UserCircle },
        { id: 'config', label: 'Configuración App', icon: Settings },
    ];

    const colorPresets = ['#6366f1', '#10b981', '#f59e0b', '#ef4444', '#ec4899', '#8b5cf6', '#06b6d4', '#84cc16'];

    return (
        <div className="settings-page">
            <header className="page-header">
                <div className="header-content">
                    <div className="header-icon-box">
                        <Settings size={28} />
                    </div>
                    <div>
                        <h1>Configuración</h1>
                        <p>Ajustes globales de PiensaPlay</p>
                    </div>
                </div>
            </header>

            {/* Tabs */}
            <div className="settings-tabs">
                {tabs.map(tab => (
                    <button
                        key={tab.id}
                        className={`tab-btn ${activeTab === tab.id ? 'active' : ''}`}
                        onClick={() => setActiveTab(tab.id)}
                    >
                        <tab.icon size={18} />
                        <span>{tab.label}</span>
                    </button>
                ))}
            </div>

            {loading ? (
                <div className="loading-state">
                    <Loader2 className="spin" size={32} />
                    <p>Cargando configuración...</p>
                </div>
            ) : (
                <>
                    {/* Default Avatars Tab */}
                    {activeTab === 'avatars' && (
                        <section className="settings-section">
                            <div className="section-header">
                                <div className="header-info">
                                    <h2>Avatares para Selección Inicial</h2>
                                    <p>Estos avatares estarán disponibles cuando un estudiante cree su cuenta.</p>
                                </div>
                                <button className="btn btn-primary" onClick={openNewAvatarModal}>
                                    <Plus size={18} />
                                    <span>Nuevo Avatar</span>
                                </button>
                            </div>

                            <div className="default-avatars-grid">
                                {defaultAvatars.map((avatar, index) => (
                                    <motion.div
                                        key={avatar.id}
                                        layout
                                        initial={{ opacity: 0, scale: 0.9 }}
                                        animate={{ opacity: 1, scale: 1 }}
                                        className="default-avatar-card"
                                        style={{ '--accent-color': avatar.color || '#6366f1' }}
                                    >
                                        <div className="avatar-image-wrapper">
                                            {avatar.imageUrl ? (
                                                <img src={avatar.imageUrl} alt={avatar.name} />
                                            ) : (
                                                <div className="avatar-placeholder" style={{ backgroundColor: avatar.color }}>
                                                    <UserCircle size={40} />
                                                </div>
                                            )}
                                        </div>
                                        <div className="avatar-details">
                                            <h4>{avatar.name || `Avatar ${index + 1}`}</h4>
                                            <div className="color-indicator" style={{ backgroundColor: avatar.color }}></div>
                                        </div>
                                        <div className="avatar-card-actions">
                                            <button className="icon-btn edit" onClick={() => openEditAvatarModal(avatar)}>
                                                <Edit2 size={14} />
                                            </button>
                                            <button className="icon-btn delete" onClick={() => handleDeleteAvatar(avatar.id)}>
                                                <Trash2 size={14} />
                                            </button>
                                        </div>
                                    </motion.div>
                                ))}

                                {/* Add New Card */}
                                <div className="add-avatar-card" onClick={openNewAvatarModal}>
                                    <div className="add-icon">
                                        <Plus size={32} />
                                    </div>
                                    <span>Añadir Avatar</span>
                                </div>
                            </div>

                            {defaultAvatars.length === 0 && (
                                <div className="empty-avatars-state">
                                    <UserCircle size={64} strokeWidth={1} />
                                    <h3>Sin avatares iniciales</h3>
                                    <p>Los estudiantes podrán elegir uno de estos avatares al registrarse</p>
                                    <button className="btn btn-primary" onClick={openNewAvatarModal}>
                                        <Plus size={18} /> Crear primer avatar
                                    </button>
                                </div>
                            )}
                        </section>
                    )}

                    {/* App Config Tab */}
                    {activeTab === 'config' && (
                        <section className="settings-section">
                            <div className="section-header">
                                <div className="header-info">
                                    <h2>Configuración General</h2>
                                    <p>Ajustes que afectan el comportamiento global de la aplicación.</p>
                                </div>
                                <button className="btn btn-primary" onClick={saveAppConfig} disabled={saving}>
                                    <Save size={18} />
                                    <span>{saving ? 'Guardando...' : 'Guardar Cambios'}</span>
                                </button>
                            </div>

                            <div className="config-sections">
                                {/* Rewards Section */}
                                <div className="config-category">
                                    <div className="category-header">
                                        <Award size={20} />
                                        <h3>Sistema de Recompensas</h3>
                                    </div>
                                    <div className="config-grid">
                                        <div className="config-card">
                                            <div className="config-icon coins">
                                                <Coins size={20} />
                                            </div>
                                            <div className="config-content">
                                                <label>Balance Inicial</label>
                                                <p>Monedas al registrarse</p>
                                            </div>
                                            <input
                                                type="number"
                                                className="config-input"
                                                value={appConfig.initialWalletBalance}
                                                onChange={(e) => setAppConfig({ ...appConfig, initialWalletBalance: parseInt(e.target.value) || 0 })}
                                            />
                                        </div>

                                        <div className="config-card">
                                            <div className="config-icon xp">
                                                <Zap size={20} />
                                            </div>
                                            <div className="config-content">
                                                <label>XP por Actividad</label>
                                                <p>Experiencia base ganada</p>
                                            </div>
                                            <input
                                                type="number"
                                                className="config-input"
                                                value={appConfig.xpPerActivity}
                                                onChange={(e) => setAppConfig({ ...appConfig, xpPerActivity: parseInt(e.target.value) || 0 })}
                                            />
                                        </div>

                                        <div className="config-card">
                                            <div className="config-icon coins">
                                                <Coins size={20} />
                                            </div>
                                            <div className="config-content">
                                                <label>Monedas por Juego</label>
                                                <p>Recompensa por completar</p>
                                            </div>
                                            <input
                                                type="number"
                                                className="config-input"
                                                value={appConfig.coinsPerActivity}
                                                onChange={(e) => setAppConfig({ ...appConfig, coinsPerActivity: parseInt(e.target.value) || 0 })}
                                            />
                                        </div>
                                    </div>
                                </div>

                                {/* Features Section */}
                                <div className="config-category">
                                    <div className="category-header">
                                        <Settings size={20} />
                                        <h3>Funcionalidades</h3>
                                    </div>
                                    <div className="toggles-grid">
                                        <div className="toggle-card">
                                            <div className="toggle-icon">
                                                <ShoppingBag size={20} />
                                            </div>
                                            <div className="toggle-info">
                                                <label>Tienda de Recompensas</label>
                                                <p>Comprar items con monedas</p>
                                            </div>
                                            <label className="toggle-switch">
                                                <input
                                                    type="checkbox"
                                                    checked={appConfig.enableShop}
                                                    onChange={(e) => setAppConfig({ ...appConfig, enableShop: e.target.checked })}
                                                />
                                                <span className="slider"></span>
                                            </label>
                                        </div>

                                        <div className="toggle-card">
                                            <div className="toggle-icon">
                                                <BookOpen size={20} />
                                            </div>
                                            <div className="toggle-info">
                                                <label>Glosario Global</label>
                                                <p>Términos educativos</p>
                                            </div>
                                            <label className="toggle-switch">
                                                <input
                                                    type="checkbox"
                                                    checked={appConfig.enableGlossary}
                                                    onChange={(e) => setAppConfig({ ...appConfig, enableGlossary: e.target.checked })}
                                                />
                                                <span className="slider"></span>
                                            </label>
                                        </div>

                                        <div className="toggle-card danger">
                                            <div className="toggle-icon danger">
                                                <Lock size={20} />
                                            </div>
                                            <div className="toggle-info">
                                                <label>Modo Mantenimiento</label>
                                                <p>Bloquear acceso temporalmente</p>
                                            </div>
                                            <label className="toggle-switch">
                                                <input
                                                    type="checkbox"
                                                    checked={appConfig.maintenanceMode}
                                                    onChange={(e) => setAppConfig({ ...appConfig, maintenanceMode: e.target.checked })}
                                                />
                                                <span className="slider danger"></span>
                                            </label>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </section>
                    )}
                </>
            )}

            {/* Avatar Modal with Image Upload */}
            <AnimatePresence>
                {showAvatarModal && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="modal-overlay"
                        onClick={() => setShowAvatarModal(false)}
                    >
                        <motion.div
                            initial={{ y: 50, opacity: 0 }}
                            animate={{ y: 0, opacity: 1 }}
                            exit={{ y: 50, opacity: 0 }}
                            className="modal-content avatar-upload-modal"
                            onClick={e => e.stopPropagation()}
                        >
                            <div className="modal-header">
                                <h2>{editingAvatar ? 'Editar Avatar' : 'Nuevo Avatar Inicial'}</h2>
                                <button className="close-btn" onClick={() => setShowAvatarModal(false)}>
                                    <X size={20} />
                                </button>
                            </div>

                            <form onSubmit={handleSaveAvatar} className="avatar-upload-form">
                                <div className="upload-section">
                                    <div
                                        className={`image-upload-area ${avatarForm.imageUrl ? 'has-image' : ''}`}
                                        style={{ borderColor: avatarForm.color }}
                                    >
                                        {uploading ? (
                                            <div className="upload-progress-state">
                                                <Loader2 className="spin" size={32} />
                                                <span>Subiendo... {Math.round(uploadProgress)}%</span>
                                                <div className="progress-bar">
                                                    <div className="progress-fill" style={{ width: `${uploadProgress}%` }}></div>
                                                </div>
                                            </div>
                                        ) : avatarForm.imageUrl ? (
                                            <div className="image-preview-wrapper">
                                                <img src={avatarForm.imageUrl} alt="Avatar Preview" />
                                                <button
                                                    type="button"
                                                    className="change-image-btn"
                                                    onClick={() => fileInputRef.current?.click()}
                                                >
                                                    <Upload size={16} /> Cambiar
                                                </button>
                                            </div>
                                        ) : (
                                            <label className="upload-label">
                                                <input
                                                    type="file"
                                                    accept="image/*"
                                                    ref={fileInputRef}
                                                    onChange={(e) => handleImageUpload(e.target.files[0])}
                                                    hidden
                                                />
                                                <div className="upload-icon-circle">
                                                    <Image size={32} />
                                                </div>
                                                <span>Subir Imagen del Avatar</span>
                                                <small>PNG, JPG hasta 5MB</small>
                                            </label>
                                        )}
                                    </div>
                                    <input
                                        type="file"
                                        accept="image/*"
                                        ref={fileInputRef}
                                        onChange={(e) => handleImageUpload(e.target.files[0])}
                                        hidden
                                    />
                                </div>

                                <div className="form-fields">
                                    <div className="form-group">
                                        <label>Nombre del Avatar</label>
                                        <input
                                            type="text"
                                            value={avatarForm.name}
                                            onChange={(e) => setAvatarForm({ ...avatarForm, name: e.target.value })}
                                            placeholder="Ej: Explorador Cósmico"
                                            required
                                        />
                                    </div>

                                    <div className="form-group">
                                        <label>Color de Fondo</label>
                                        <div className="color-selector">
                                            <input
                                                type="color"
                                                value={avatarForm.color}
                                                onChange={(e) => setAvatarForm({ ...avatarForm, color: e.target.value })}
                                            />
                                            <div className="color-presets">
                                                {colorPresets.map(color => (
                                                    <button
                                                        key={color}
                                                        type="button"
                                                        className={`color-preset ${avatarForm.color === color ? 'active' : ''}`}
                                                        style={{ backgroundColor: color }}
                                                        onClick={() => setAvatarForm({ ...avatarForm, color })}
                                                    />
                                                ))}
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <div className="modal-footer">
                                    <button type="button" className="btn" onClick={() => setShowAvatarModal(false)}>
                                        Cancelar
                                    </button>
                                    <button type="submit" className="btn btn-primary" disabled={uploading || !avatarForm.imageUrl}>
                                        {editingAvatar ? 'Actualizar' : 'Crear Avatar'}
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

export default SettingsPage;
