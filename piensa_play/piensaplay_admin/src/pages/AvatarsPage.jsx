import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, where, onSnapshot, addDoc, updateDoc, doc, deleteDoc } from 'firebase/firestore';
import { UserCircle, Plus, Edit2, Trash2, Shield, Star, Zap, Palette } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import './AvatarsPage.css';

const AvatarsPage = () => {
    const [items, setItems] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingItem, setEditingItem] = useState(null);

    // Form states
    const [formData, setFormData] = useState({
        name: '',
        description: '',
        price: 0,
        rarity: 'common',
        color: '#4caf50',
        type: 'avatar'
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
            color: '#4caf50',
            type: 'avatar'
        });
    };

    const getRarityIcon = (rarity) => {
        switch (rarity) {
            case 'legendary': return <Star size={16} />;
            case 'epic': return <Zap size={16} />;
            case 'rare': return <Shield size={16} />;
            default: return <Palette size={16} />;
        }
    };

    return (
        <div className="avatars-page">
            <header className="page-header">
                <div className="header-content">
                    <h1>Gestión de Avatares</h1>
                    <p>Personaliza los personajes que los estudiantes pueden adquirir en la tienda.</p>
                </div>
                <button className="btn btn-primary" onClick={() => { setEditingItem(null); resetForm(); setShowModal(true); }}>
                    <Plus size={20} />
                    <span>Nuevo Avatar</span>
                </button>
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
                                className="card avatar-card"
                            >
                                <div className={`rarity-tag ${item.rarity}`}>
                                    {getRarityIcon(item.rarity)}
                                    <span>{item.rarity.toUpperCase()}</span>
                                </div>

                                <div className="avatar-preview" style={{ backgroundColor: `${item.color}20`, color: item.color }}>
                                    <UserCircle size={64} />
                                </div>

                                <div className="avatar-info">
                                    <h3>{item.name}</h3>
                                    <p className="description">{item.description}</p>
                                    <div className="price-tag">
                                        <Zap size={14} className="price-icon" />
                                        <span>{item.price} Monedas</span>
                                    </div>
                                </div>

                                <div className="card-actions">
                                    <button className="action-btn edit" onClick={() => {
                                        setEditingItem(item);
                                        setFormData({ ...item });
                                        setShowModal(true);
                                    }}>
                                        <Edit2 size={18} />
                                    </button>
                                    <button className="action-btn delete" onClick={() => handleDelete(item.id)}>
                                        <Trash2 size={18} />
                                    </button>
                                </div>
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </div>
            )}

            {showModal && (
                <div className="modal-overlay">
                    <motion.div
                        initial={{ opacity: 0, scale: 0.9 }}
                        animate={{ opacity: 1, scale: 1 }}
                        className="card modal-content"
                    >
                        <h2>{editingItem ? 'Editar Avatar' : 'Añadir Nuevo Avatar'}</h2>
                        <form onSubmit={handleSave} className="avatar-form">
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
                                />
                            </div>

                            <div className="form-row">
                                <div className="form-group">
                                    <label>Precio (Monedas)</label>
                                    <input
                                        type="number"
                                        value={formData.price}
                                        onChange={(e) => setFormData({ ...formData, price: parseInt(e.target.value) })}
                                        required
                                    />
                                </div>
                                <div className="form-group">
                                    <label>Rareza</label>
                                    <select
                                        value={formData.rarity}
                                        onChange={(e) => setFormData({ ...formData, rarity: e.target.value })}
                                    >
                                        <option value="common">Común</option>
                                        <option value="rare">Raro</option>
                                        <option value="epic">Épico</option>
                                        <option value="legendary">Legendario</option>
                                    </select>
                                </div>
                            </div>

                            <div className="form-group">
                                <label>Color Temático</label>
                                <div className="color-input-wrapper">
                                    <input
                                        type="color"
                                        value={formData.color}
                                        onChange={(e) => setFormData({ ...formData, color: e.target.value })}
                                    />
                                    <span>{formData.color}</span>
                                </div>
                            </div>

                            <div className="modal-footer">
                                <button type="button" className="btn" onClick={() => setShowModal(false)}>Cancelar</button>
                                <button type="submit" className="btn btn-primary">
                                    {editingItem ? 'Actualizar' : 'Crear Avatar'}
                                </button>
                            </div>
                        </form>
                    </motion.div>
                </div>
            )}
        </div>
    );
};

export default AvatarsPage;
