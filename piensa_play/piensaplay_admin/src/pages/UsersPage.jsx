import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, where, onSnapshot, updateDoc, doc, deleteDoc } from 'firebase/firestore';
import { Users, Search, GraduationCap, School, Shield, MoreVertical } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import './UsersPage.css';

const UsersPage = () => {
    const [tutors, setTutors] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');

    useEffect(() => {
        // Query only tutors (or all teachers)
        const q = query(collection(db, 'users'), where('role', 'in', ['tutor', 'teacher', 'admin']));
        const unsubscribe = onSnapshot(q, (snapshot) => {
            const usersData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
            setTutors(usersData);
            setLoading(false);
        });
        return () => unsubscribe();
    }, []);

    const toggleRole = async (user) => {
        const newRole = user.role === 'admin' ? 'tutor' : 'admin';
        try {
            await updateDoc(doc(db, 'users', user.id), { role: newRole });
        } catch (error) {
            console.error("Error updating role: ", error);
        }
    };

    const filteredTutors = tutors.filter(t =>
        t.displayName?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        t.email?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="users-page">
            <header className="page-header">
                <div className="header-content">
                    <h1>Gestión de Tutores</h1>
                    <p>Administra los accesos y roles de los docentes en la plataforma.</p>
                </div>
            </header>

            <div className="search-bar-container">
                <div className="search-bar glass">
                    <Search size={20} className="search-icon" />
                    <input
                        type="text"
                        placeholder="Buscar por nombre o correo..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>
            </div>

            {loading ? (
                <div className="loading-state">Cargando docentes...</div>
            ) : (
                <div className="users-list-container glass">
                    <table className="users-table">
                        <thead>
                            <tr>
                                <th>Usuario</th>
                                <th>Email</th>
                                <th>Institución</th>
                                <th>Rol</th>
                                <th>Acciones</th>
                            </tr>
                        </thead>
                        <tbody>
                            <AnimatePresence>
                                {filteredTutors.map((user) => (
                                    <motion.tr
                                        key={user.id}
                                        initial={{ opacity: 0 }}
                                        animate={{ opacity: 1 }}
                                        exit={{ opacity: 0 }}
                                    >
                                        <td>
                                            <div className="user-info-cell">
                                                <div className="user-avatar" style={{ backgroundColor: `${user.role === 'admin' ? 'var(--danger)' : 'var(--primary-light)'}20` }}>
                                                    <Users size={20} color={user.role === 'admin' ? 'var(--danger)' : 'var(--primary-light)'} />
                                                </div>
                                                <span>{user.displayName || 'Sin nombre'}</span>
                                            </div>
                                        </td>
                                        <td>{user.email}</td>
                                        <td>
                                            <div className="school-cell">
                                                <School size={16} />
                                                <span>{user.schoolName || 'Global'}</span>
                                            </div>
                                        </td>
                                        <td>
                                            <span className={`role-badge ${user.role}`}>
                                                {user.role === 'admin' ? <Shield size={12} /> : <GraduationCap size={12} />}
                                                {user.role}
                                            </span>
                                        </td>
                                        <td>
                                            <div className="table-actions">
                                                <button
                                                    className="btn-text"
                                                    onClick={() => toggleRole(user)}
                                                    title="Cambiar Rol"
                                                >
                                                    Cambiar Rol
                                                </button>
                                            </div>
                                        </td>
                                    </motion.tr>
                                ))}
                            </AnimatePresence>
                        </tbody>
                    </table>
                </div>
            )}
        </div>
    );
};

export default UsersPage;
