import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, onSnapshot, deleteDoc, doc } from 'firebase/firestore';
import { School, Users, Trash2, Calendar, Search, BookOpen } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import './ClassesPage.css';

const ClassesPage = () => {
    const [classes, setClasses] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        const q = query(collection(db, 'classes'));
        const unsubscribe = onSnapshot(q, (snapshot) => {
            const classesData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setClasses(classesData);
            setLoading(false);
        });
        return () => unsubscribe();
    }, []);

    const handleDelete = async (id) => {
        if (window.confirm('¿Estás seguro de eliminar esta clase? Esto no eliminará a los estudiantes, pero perderán el acceso a la unidad de la clase.')) {
            try {
                await deleteDoc(doc(db, 'classes', id));
            } catch (error) {
                console.error("Error deleting class: ", error);
            }
        }
    };

    const filteredClasses = classes.filter(c =>
        c.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.description?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        c.code?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="classes-page">
            <header className="page-header">
                <div className="header-content">
                    <h1>Control de Clases</h1>
                    <p>Supervisa todas las secciones y grupos creados por los tutores.</p>
                </div>
            </header>

            <div className="search-bar-container">
                <div className="search-bar glass">
                    <Search size={20} className="search-icon" />
                    <input
                        type="text"
                        placeholder="Buscar por nombre o código..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>
            </div>

            {loading ? (
                <div className="loading-state">Cargando clases...</div>
            ) : (
                <div className="classes-grid">
                    <AnimatePresence>
                        {filteredClasses.map((clase) => (
                            <motion.div
                                key={clase.id}
                                layout
                                initial={{ opacity: 0, scale: 0.9 }}
                                animate={{ opacity: 1, scale: 1 }}
                                exit={{ opacity: 0, scale: 0.9 }}
                                className="card class-card"
                            >
                                <div className="class-header">
                                    <div className="class-icon" style={{ backgroundColor: `${clase.color ? `#${clase.color.toString(16).padStart(6, '0').slice(-6)}` : 'var(--primary-light)'}20` }}>
                                        <School size={24} color={clase.color ? `#${clase.color.toString(16).padStart(6, '0').slice(-6)}` : 'var(--primary-light)'} />
                                    </div>
                                    <button className="delete-btn" onClick={() => handleDelete(clase.id)}>
                                        <Trash2 size={18} />
                                    </button>
                                </div>

                                <div className="class-info">
                                    <h3>{clase.name || 'Clase sin nombre'}</h3>
                                    <p className="school-name">{clase.description || 'Sin descripción'}</p>

                                    <div className="class-stats">
                                        <div className="stat">
                                            <Users size={16} />
                                            <span>{clase.studentCount || 0} Estudiantes</span>
                                        </div>
                                    </div>

                                    <div className="tutor-info">
                                        <div className="tutor-avatar">
                                            T
                                        </div>
                                        <div className="tutor-details">
                                            <p className="label">Tutor ID</p>
                                            <p className="name">{clase.tutorId || 'Desconocido'}</p>
                                        </div>
                                    </div>
                                </div>

                                <div className="class-footer">
                                    <div className="date">
                                        <Calendar size={14} />
                                        <span>Código: <strong>{clase.code || '------'}</strong></span>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </AnimatePresence>
                    {filteredClasses.length === 0 && (
                        <div className="empty-state">
                            <School size={48} />
                            <p>No se encontraron clases</p>
                        </div>
                    )}
                </div>
            )}
        </div>
    );
};

export default ClassesPage;
