import React, { useState, useEffect, useRef } from 'react';
import { db } from '../firebase';
import { collection, query, where, onSnapshot, addDoc, updateDoc, doc, deleteDoc } from 'firebase/firestore';
import { uploadToCloudinary } from '../cloudinary';
import { UserCircle, Plus, Edit2, Trash2, Shield, Star, Zap, Palette, Upload, Image, X, Loader2 } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import './AvatarsPage.css';

const AvatarsPage = () => {
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingItem, setEditingItem] = useState(null);
    const [uploading, setUploading] = useState(false);
    const [uploadProgress, setUploadProgress] = useState(0);
    const fileInputRef = useRef(null);

    const [formData, setFormData] = useState({
        name: '',
        description: '',
        price: 0,
        rarity: 'common',
        color: '#6366f1',
        type: 'avatar',
        imageUrl: ''
    });

    useEffect(() => {
        const q = query(collection(db, 'shop_items'), where('type', '==', 'avatar'));
        const unsubscribe = onSnapshot(q, (snapshot) => {
            const itemsData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setItems(itemsData);
            setLoading(false);
        });
        return () => unsubscribe();
    }, []);

    const handleImageUpload = async (file) => {
        if (!file) return;

        const maxSize = 5 * 1024 * 1024; // 5MB
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
            setFormData(prev => ({ ...prev, imageUrl: result.url }));
            setUploading(false);
        } catch (error) {
            console.error('Cloudinary Upload error:', error);
            setUploading(false);
            alert('Error al subir la imagen: ' + error.message);
        }
    };

    const handleRemoveImage = () => {
        setFormData(prev => ({ ...prev, imageUrl: '' }));
    };

    const handleSave = async (e) => {
        e.preventDefault();
        try {
            if (editingItem) {
                await updateDoc(doc(db, 'shop_items', editingItem.id), formData);
            } else {
                await addDoc(collection(db, 'shop_items'), formData);
            }
            setShowModal(false);
            setEditingItem(null);
            resetForm();
        } catch (error) {
            console.error("Error saving avatar:", error);
        }
    };

    const handleDelete = async (id) => {
        if (window.confirm('¿Estás seguro de eliminar este avatar?')) {
            await deleteDoc(doc(db, 'shop_items', id));
        }
    };

    const resetForm = () => {
        setFormData({
            name: '',
            description: '',
            price: 0,
            rarity: 'common',
            color: '#6366f1',
            type: 'avatar',
            imageUrl: ''
        });
    };

    const getRarityIcon = (rarity) => {
        switch (rarity) {
            case 'legendary': return <Star size={14} />;
            case 'epic': return <Zap size={14} />;
            case 'rare': return <Shield size={14} />;
            default: return <Palette size={14} />;
        }
    };

    const getRarityColor = (rarity) => {
        switch (rarity) {
            case 'legendary': return '#fbbf24';
            case 'epic': return '#a855f7';
            case 'rare': return '#3b82f6';
            default: return '#94a3b8';
        }
    };

    return (
        <div className="avatars-page">
            <header className="page-header">
                <div className="header-info">
                    <div className="header-title-row">
                        <div className="header-icon-box">
                            <UserCircle size={28} />
                        </div>
                        <div>
                            <h1>Estudio de Avatares</h1>
                            <p>Crea y personaliza la identidad visual de los estudiantes.</p>
                        </div>
                    </div>
                </div>

                <div className="header-actions">
                    <div className="header-stats">
                        <div className="stat-pill">
                            <span className="stat-value">{items.length}</span>
                            <span className="stat-label">Total</span>
                        </div>
                        <div className="stat-pill legendary">
                            <span className="stat-value">{items.filter(i => i.rarity === 'legendary').length}</span>
                            <span className="stat-label">Leyendas</span>
                        </div>
                    </div>
                    <button className="btn btn-primary btn-glow" onClick={() => { setEditingItem(null); resetForm(); setShowModal(true); }}>
                        <Plus size={20} />
                        <span>Crear Avatar</span>
                    </button>
                </div>
            </header>

            {loading ? (
                <div className="loading-state">Cargando catálogo...</div>
            ) : (
                <div className="avatars-grid">
                    <AnimatePresence>
                        {items.map((item) => (
                            <motion.div
                                key={item.id}
                                layout
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, scale: 0.9 }}
                                className="avatar-card"
                            >
                                <div className="avatar-card-inner">
                                    <div className={`rarity-tag ${item.rarity}`}>
                                        {getRarityIcon(item.rarity)}
                                        <span>{item.rarity}</span>
                                    </div>

                                    <div className="avatar-orb" style={{
                                        '--orb-color': item.color,
                                        background: `radial-gradient(circle at 30% 30%, ${item.color}40, ${item.color}10)`
                                    }}>
                                        {item.imageUrl ? (
                                            <img src={item.imageUrl} alt={item.name} className="avatar-img-main" />
                                        ) : (
                                            <UserCircle size={64} style={{ color: item.color }} />
                                        )}
                                        <div className="orb-glow" style={{ boxShadow: `0 0 30px ${item.color}30` }}></div>
                                    </div>

                                    <div className="avatar-details">
                                        <h3 className="avatar-name-display">{item.name}</h3>
                                        <p className="avatar-desc-display">{item.description}</p>

                                        <div className="avatar-footer-meta">
                                            <div className="price-badge">
                                                <Zap size={14} />
                                                <span>{item.price}</span>
                                            </div>
                                            <div className="card-controls">
                                                <button className="action-btn-circle edit" title="Editar" onClick={() => {
                                                    setEditingItem(item);
                                                    setFormData({ ...item, imageUrl: item.imageUrl || '' });
                                                    setShowModal(true);
                                                }}>
                                                    <Edit2 size={16} />
                                                </button>
                                                <button className="action-btn-circle delete" title="Eliminar" onClick={() => handleDelete(item.id)}>
                                                    <Trash2 size={16} />
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </AnimatePresence>

                    {items.length === 0 && (
                        <div className="empty-state">
                            <UserCircle size={48} />
                            <h3>No hay avatares</h3>
                            <p>Crea el primer avatar para la tienda.</p>
                        </div>
                    )}
                </div>
            )}

            {/* Avatar Creation/Edit Modal */}
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
                            initial={{ opacity: 0, scale: 0.9, y: 20 }}
                            animate={{ opacity: 1, scale: 1, y: 0 }}
                            exit={{ opacity: 0, scale: 0.9 }}
                            className="modal-content avatar-modal"
                            onClick={(e) => e.stopPropagation()}
                        >
                            <div className="modal-header-studio">
                                <div className="header-badge">ESTUDIO DE DISEÑO</div>
                                <h2>{editingItem ? 'Refinar Avatar' : 'Crear Identidad'}</h2>
                                <button className="close-modal-btn" onClick={() => setShowModal(false)}><X size={20} /></button>
                            </div>

                            <div className="avatar-editor">
                                {/* Live Preview */}
                                <div className="avatar-live-preview">
                                    <h4>Vista Previa</h4>
                                    <div className="preview-card" style={{ borderColor: formData.color }}>
                                        <div className={`preview-rarity ${formData.rarity}`}>
                                            {getRarityIcon(formData.rarity)}
                                            <span>{formData.rarity.toUpperCase()}</span>
                                        </div>
                                        <div className="preview-avatar" style={{
                                            backgroundColor: formData.imageUrl ? 'transparent' : `${formData.color}20`,
                                            borderColor: formData.color
                                        }}>
                                            {formData.imageUrl ? (
                                                <img src={formData.imageUrl} alt="Preview" />
                                            ) : (
                                                <UserCircle size={64} style={{ color: formData.color }} />
                                            )}
                                        </div>
                                        <h4 className="preview-name">{formData.name || 'Nombre del Avatar'}</h4>
                                        <p className="preview-desc">{formData.description || 'Descripción...'}</p>
                                        <div className="preview-price">
                                            <Zap size={14} />
                                            <span>{formData.price || 0} Monedas</span>
                                        </div>
                                    </div>
                                </div>

                                {/* Form */}
                                <form onSubmit={handleSave} className="avatar-form">
                                    {/* Image Upload */}
                                    <div className="form-group">
                                        <label><Image size={14} /> Imagen del Avatar</label>
                                        <div className="image-upload-zone">
                                            {uploading ? (
                                                <div className="upload-progress">
                                                    <Loader2 size={24} className="spin" />
                                                    <span>Subiendo... {Math.round(uploadProgress)}%</span>
                                                    <div className="progress-bar">
                                                        <div className="progress-fill" style={{ width: `${uploadProgress}%` }}></div>
                                                    </div>
                                                </div>
                                            ) : formData.imageUrl ? (
                                                <div className="image-preview">
                                                    <img src={formData.imageUrl} alt="Avatar" />
                                                    <button type="button" className="remove-image" onClick={handleRemoveImage}>
                                                        <X size={16} />
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
                                                    <Upload size={24} />
                                                    <span>Subir imagen</span>
                                                    <small>PNG, JPG hasta 5MB</small>
                                                </label>
                                            )}
                                        </div>
                                    </div>

                                    <div className="form-group">
                                        <label>Nombre del Avatar</label>
                                        <input
                                            type="text"
                                            value={formData.name}
                                            onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                            required
                                            placeholder="Ej: Ciber Explorador"
                                        />
                                    </div>

                                    <div className="form-group">
                                        <label>Descripción</label>
                                        <textarea
                                            value={formData.description}
                                            onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                                            placeholder="Pequeña biografía o lema..."
                                            rows={2}
                                        />
                                    </div>

                                    <div className="form-row">
                                        <div className="form-group">
                                            <label>Precio (Monedas)</label>
                                            <input
                                                type="number"
                                                value={formData.price}
                                                onChange={(e) => setFormData({ ...formData, price: parseInt(e.target.value) || 0 })}
                                                min="0"
                                                required
                                            />
                                        </div>
                                        <div className="rarity-selector-v2">
                                            <label>Nivel de Rareza</label>
                                            <div className="rarity-options">
                                                {['common', 'rare', 'epic', 'legendary'].map(rarity => (
                                                    <button
                                                        key={rarity}
                                                        type="button"
                                                        className={`rarity-btn-v2 ${rarity} ${formData.rarity === rarity ? 'selected' : ''}`}
                                                        onClick={() => setFormData({ ...formData, rarity })}
                                                    >
                                                        {getRarityIcon(rarity)}
                                                        <span>{rarity.charAt(0).toUpperCase() + rarity.slice(1)}</span>
                                                    </button>
                                                ))}
                                            </div>
                                        </div>
                                    </div>

                                    <div className="form-group">
                                        <label>Color Temático</label>
                                        <div className="color-picker-row">
                                            <input
                                                type="color"
                                                value={formData.color}
                                                onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                                            />
                                            <span className="color-value">{formData.color}</span>
                                            <div className="color-presets">
                                                {['#6366f1', '#10b981', '#f59e0b', '#ef4444', '#ec4899', '#8b5cf6'].map(color => (
                                                    <button
                                                        key={color}
                                                        type="button"
                                                        className={`color-preset ${formData.color === color ? 'active' : ''}`}
                                                        style={{ background: color }}
                                                        onClick={() => setFormData({ ...formData, color })}
                                                    />
                                                ))}
                                            </div>
                                        </div>
                                    </div>

                                    <div className="modal-footer">
                                        <button type="button" className="btn" onClick={() => setShowModal(false)}>Cancelar</button>
                                        <button type="submit" className="btn btn-primary" disabled={uploading}>
                                            {editingItem ? 'Actualizar' : 'Crear Avatar'}
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default AvatarsPage;
