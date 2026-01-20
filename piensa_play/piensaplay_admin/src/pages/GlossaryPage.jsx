import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, onSnapshot, addDoc, updateDoc, doc, deleteDoc } from 'firebase/firestore';
import { BookOpen, Plus, Edit2, Trash2, Search, Tag } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import './GlossaryPage.css';

const GlossaryPage = () => {
    const [terms, setTerms] = useState([]);
    const [loading, setLoading] = useState(true);
    const [showModal, setShowModal] = useState(false);
    const [editingTerm, setEditingTerm] = useState(null);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        const q = query(collection(db, 'glossary'));
        const unsubscribe = onSnapshot(q, (snapshot) => {
            const termsData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setTerms(termsData.sort((a, b) => a.term.localeCompare(b.term)));
            setLoading(false);
        });
        return () => unsubscribe();
    }, []);

    const handleDelete = async (id) => {
        if (window.confirm('¿Estás seguro de que deseas eliminar este término?')) {
            try {
                await deleteDoc(doc(db, 'glossary', id));
            } catch (error) {
                console.error("Error deleting term: ", error);
            }
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        const formData = new FormData(e.target);
        const termData = {
            term: formData.get('term'),
            definition: formData.get('definition'),
            category: formData.get('category'),
            updatedAt: new Date().toISOString()
        };

        try {
            if (editingTerm) {
                await updateDoc(doc(db, 'glossary', editingTerm.id), termData);
            } else {
                await addDoc(collection(db, 'glossary'), termData);
            }
            setShowModal(false);
            setEditingTerm(null);
        } catch (error) {
            console.error("Error saving term: ", error);
        }
    };

    const filteredTerms = terms.filter(t =>
        t.term.toLowerCase().includes(searchTerm.toLowerCase()) ||
        t.category?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="glossary-page">
            <header className="page-header">
                <div className="header-content">
                    <h1>Glosario Maestro</h1>
                    <p>Gestiona los términos educativos y definiciones para los estudiantes.</p>
                </div>
                <button className="btn btn-primary" onClick={() => { setEditingTerm(null); setShowModal(true); }}>
                    <Plus size={20} />
                    <span>Nuevo Término</span>
                </button>
            </header>

            <div className="search-bar-container">
                <div className="search-bar glass">
                    <Search size={20} className="search-icon" />
                    <input
                        type="text"
                        placeholder="Buscar términos o categorías..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>
            </div>

            {loading ? (
                <div className="loading-state">Cargando glosario...</div>
            ) : (
                <div className="terms-grid">
                    <AnimatePresence>
                        {filteredTerms.map((term) => (
                            <motion.div
                                key={term.id}
                                layout
                                initial={{ opacity: 0, scale: 0.9 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0, scale: 0.9 }}
                                className="card term-card"
                            >
                                <div className="term-header">
                                    <div className="term-info">
                                        <h3>{term.term}</h3>
                                        <span className="category-badge">
                                            <Tag size={12} />
                                            {term.category || 'General'}
                                        </span>
                                    </div>
                                    <div className="term-actions">
                                        <button className="icon-btn" onClick={() => { setEditingTerm(term); setShowModal(true); }}>
                                            <Edit2 size={16} />
                                        </button>
                                        <button className="icon-btn delete" onClick={() => handleDelete(term.id)}>
                                            <Trash2 size={16} />
                                        </button>
                                    </div>
                                </div>
                                <p className="definition">{term.definition}</p>
                            </motion.div>
                        ))}
                    </AnimatePresence>
                </div>
            )}

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
                                <h2>{editingTerm ? 'Editar Término' : 'Nuevo Término'}</h2>
                                <p>Ingresa la información detallada del concepto educativo.</p>
                            </div>

                            <form onSubmit={handleSubmit} className="term-form">
                                <div className="form-group">
                                    <label>Término</label>
                                    <input
                                        name="term"
                                        defaultValue={editingTerm?.term}
                                        required
                                        placeholder="Ej: Fotosíntesis"
                                    />
                                </div>
                                <div className="form-group">
                                    <label>Categoría</label>
                                    <input
                                        name="category"
                                        defaultValue={editingTerm?.category}
                                        required
                                        placeholder="Ej: Biología"
                                    />
                                </div>
                                <div className="form-group">
                                    <label>Definición</label>
                                    <textarea
                                        name="definition"
                                        defaultValue={editingTerm?.definition}
                                        required
                                        placeholder="Escribe aquí la definición completa..."
                                        rows={4}
                                    />
                                </div>

                                <div className="modal-footer">
                                    <button type="button" className="btn" onClick={() => setShowModal(false)}>Cancelar</button>
                                    <button type="submit" className="btn btn-primary">
                                        {editingTerm ? 'Guardar Cambios' : 'Crear Término'}
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

export default GlossaryPage;
