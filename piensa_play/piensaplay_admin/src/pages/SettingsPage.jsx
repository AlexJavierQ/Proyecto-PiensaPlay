import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { doc, getDoc, setDoc, collection, getDocs, addDoc, deleteDoc, updateDoc } from 'firebase/firestore';
import {
    Settings, Save, Palette, UserCircle, Shield,
    Plus, Trash2, Edit2, Image, Coins, Star
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
    const [avatarForm, setAvatarForm] = useState({
        name: '',
        color: '#4caf50',
        icon: 'user',
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

    const handleSaveAvatar = async (e) => {
        e.preventDefault();
        try {
            if (editingAvatar) {
                await updateDoc(doc(db, 'default_avatars', editingAvatar.id), avatarForm);
            } else {
                await addDoc(collection(db, 'default_avatars'), avatarForm);
            }
            setShowAvatarModal(false);
            setEditingAvatar(null);
            setAvatarForm({ name: '', color: '#4caf50', icon: 'user', isDefault: true });
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

    const iconOptions = [
        { value: 'user', label: '👤 Usuario' },
        { value: 'star', label: '⭐ Estrella' },
        { value: 'rocket', label: '🚀 Cohete' },
        { value: 'heart', label: '❤️ Corazón' },
        { value: 'crown', label: '👑 Corona' },
        { value: 'diamond', label: '💎 Diamante' },
        { value: 'fire', label: '🔥 Fuego' },
        { value: 'lightning', label: '⚡ Rayo' },
    ];

    const tabs = [
        { id: 'avatars', label: 'Avatares Iniciales', icon: UserCircle },
        { id: 'config', label: 'Configuración App', icon: Settings },
    ];

    return (
        <div className="settings-page">
            <header className="page-header">
                <div className="header-content">
                    <h1>Configuración del Sistema</h1>
                    <p>Administra los ajustes globales de PiensaPlay</p>
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
                <div className="loading-state">Cargando configuración...</div>
            ) : (
                <>
                    {/* Default Avatars Tab */}
                    {activeTab === 'avatars' && (
                        <section className="settings-section">
                            <div className="section-header">
                                <div>
                                    <h2>Avatares para Selección Inicial</h2>
                                    <p>Estos avatares están disponibles cuando un estudiante crea su cuenta.</p>
                                </div>
                                <button className="btn btn-primary" onClick={() => {
                                    setEditingAvatar(null);
                                    setAvatarForm({ name: '', color: '#4caf50', icon: 'user', isDefault: true });
                                    setShowAvatarModal(true);
                                }}>
                                    <Plus size={18} />
                                    <span>Añadir Avatar</span>
                                </button>
                            </div>

                            <div className="avatars-grid">
                                {defaultAvatars.map((avatar, index) => (
                                    <motion.div
                                        key={avatar.id}
                                        layout
                                        initial={{ opacity: 0, scale: 0.9 }}
                                        animate={{ opacity: 1, scale: 1 }}
                                        className="card avatar-item"
                                    >
                                        <div className="avatar-preview" style={{ backgroundColor: avatar.color }}>
                                            <span className="avatar-icon">{iconOptions.find(i => i.value === avatar.icon)?.label.split(' ')[0] || '👤'}</span>
                                        </div>
                                        <div className="avatar-info">
                                            <h4>{avatar.name || `Avatar ${index + 1}`}</h4>
                                            <span className="avatar-color">{avatar.color}</span>
                                        </div>
                                        <div className="avatar-actions">
                                            <button className="icon-btn" onClick={() => {
                                                setEditingAvatar(avatar);
                                                setAvatarForm({ ...avatar });
                                                setShowAvatarModal(true);
                                            }}>
                                                <Edit2 size={16} />
                                            </button>
                                            <button className="icon-btn delete" onClick={() => handleDeleteAvatar(avatar.id)}>
                                                <Trash2 size={16} />
                                            </button>
                                        </div>
                                    </motion.div>
                                ))}
                                {defaultAvatars.length === 0 && (
                                    <div className="empty-state">
                                        <UserCircle size={48} />
                                        <p>No hay avatares configurados</p>
                                        <span>Añade avatares que verán los estudiantes al registrarse</span>
                                    </div>
                                )}
                            </div>
                        </section>
                    )}

                    {/* App Config Tab */}
                    {activeTab === 'config' && (
                        <section className="settings-section">
                            <div className="section-header">
                                <div>
                                    <h2>Configuración General</h2>
                                    <p>Ajustes que afectan el comportamiento global de la aplicación.</p>
                                </div>
                                <button className="btn btn-primary" onClick={saveAppConfig} disabled={saving}>
                                    <Save size={18} />
                                    <span>{saving ? 'Guardando...' : 'Guardar Cambios'}</span>
                                </button>
                            </div>

                            <div className="config-grid">
                                <div className="card config-card">
                                    <div className="config-icon">
                                        <Coins size={24} />
                                    </div>
                                    <div className="config-content">
                                        <label>Balance Inicial de Monedas</label>
                                        <p>Monedas que recibe un estudiante al registrarse</p>
                                        <input
                                            type="number"
                                            value={appConfig.initialWalletBalance}
                                            onChange={(e) => setAppConfig({ ...appConfig, initialWalletBalance: parseInt(e.target.value) })}
                                        />
                                    </div>
                                </div>

                                <div className="card config-card">
                                    <div className="config-icon xp">
                                        <Star size={24} />
                                    </div>
                                    <div className="config-content">
                                        <label>XP por Actividad Completada</label>
                                        <p>Experiencia base ganada al completar un juego</p>
                                        <input
                                            type="number"
                                            value={appConfig.xpPerActivity}
                                            onChange={(e) => setAppConfig({ ...appConfig, xpPerActivity: parseInt(e.target.value) })}
                                        />
                                    </div>
                                </div>

                                <div className="card config-card">
                                    <div className="config-icon coins">
                                        <Coins size={24} />
                                    </div>
                                    <div className="config-content">
                                        <label>Monedas por Actividad</label>
                                        <p>Monedas ganadas al completar un juego</p>
                                        <input
                                            type="number"
                                            value={appConfig.coinsPerActivity}
                                            onChange={(e) => setAppConfig({ ...appConfig, coinsPerActivity: parseInt(e.target.value) })}
                                        />
                                    </div>
                                </div>

                                <div className="card config-card toggle-card">
                                    <div className="toggle-info">
                                        <label>Tienda de Recompensas</label>
                                        <p>Permite a los estudiantes comprar items con monedas</p>
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

                                <div className="card config-card toggle-card">
                                    <div className="toggle-info">
                                        <label>Glosario Global</label>
                                        <p>Muestra el glosario de términos a los estudiantes</p>
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

                                <div className="card config-card toggle-card danger">
                                    <div className="toggle-info">
                                        <label>Modo Mantenimiento</label>
                                        <p>Bloquea el acceso a estudiantes temporalmente</p>
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
                        </section>
                    )}
                </>
            )}

            {/* Avatar Modal */}
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
                            className="card modal-content"
                            onClick={e => e.stopPropagation()}
                        >
                            <h2>{editingAvatar ? 'Editar Avatar' : 'Nuevo Avatar Inicial'}</h2>
                            <form onSubmit={handleSaveAvatar} className="avatar-form">
                                <div className="form-group">
                                    <label>Nombre del Avatar</label>
                                    <input
                                        type="text"
                                        value={avatarForm.name}
                                        onChange={(e) => setAvatarForm({ ...avatarForm, name: e.target.value })}
                                        placeholder="Ej: Explorador Espacial"
                                        required
                                    />
                                </div>

                                <div className="form-row">
                                    <div className="form-group">
                                        <label>Color</label>
                                        <div className="color-input">
                                            <input
                                                type="color"
                                                value={avatarForm.color}
                                                onChange={(e) => setAvatarForm({ ...avatarForm, color: e.target.value })}
                                            />
                                            <span>{avatarForm.color}</span>
                                        </div>
                                    </div>
                                    <div className="form-group">
                                        <label>Ícono</label>
                                        <select
                                            value={avatarForm.icon}
                                            onChange={(e) => setAvatarForm({ ...avatarForm, icon: e.target.value })}
                                        >
                                            {iconOptions.map(opt => (
                                                <option key={opt.value} value={opt.value}>{opt.label}</option>
                                            ))}
                                        </select>
                                    </div>
                                </div>

                                <div className="avatar-preview-large" style={{ backgroundColor: avatarForm.color }}>
                                    <span>{iconOptions.find(i => i.value === avatarForm.icon)?.label.split(' ')[0] || '👤'}</span>
                                </div>

                                <div className="modal-footer">
                                    <button type="button" className="btn" onClick={() => setShowAvatarModal(false)}>Cancelar</button>
                                    <button type="submit" className="btn btn-primary">
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
