import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, where, onSnapshot, getDocs, doc, updateDoc, deleteDoc } from 'firebase/firestore';
import {
    GraduationCap, Search, MoreVertical, Mail, Calendar,
    BookOpen, Users, Activity, Shield, ShieldOff, Trash2,
    Eye, TrendingUp, ChevronDown, Award, Clock,
    BarChart3, Layers, Gamepad2
} from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import './TutorsPage.css';

const TutorsPage = () => {
    const [tutors, setTutors] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedTutor, setSelectedTutor] = useState(null);
    const [tutorClasses, setTutorClasses] = useState([]);
    const [globalStats, setGlobalStats] = useState({
        totalClasses: 0,
        totalStudentsInClasses: 0,
        totalActivitiesCreated: 0,
        avgStudentsPerClass: 0
    });

    useEffect(() => {
        // Fetch tutors (users with role 'tutor' or 'professor')
        const tutorsQuery = query(
            collection(db, 'users'),
            where('role', 'in', ['tutor', 'professor', 'teacher'])
        );

        const unsubscribe = onSnapshot(tutorsQuery, async (snapshot) => {
            const tutorsData = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));

            // Fetch class counts for each tutor
            const tutorsWithStats = await Promise.all(tutorsData.map(async (tutor) => {
                const classesQuery = query(
                    collection(db, 'classes'),
                    where('tutorId', '==', tutor.id)
                );
                const classesSnap = await getDocs(classesQuery);
                const classes = classesSnap.docs.map(d => d.data());

                let totalStudents = 0;
                let totalActivities = 0;
                classes.forEach(c => {
                    totalStudents += c.students?.length || 0;
                    totalActivities += c.units?.reduce((acc, u) => acc + (u.games?.length || 0), 0) || 0;
                });

                return {
                    ...tutor,
                    classCount: classesSnap.size,
                    studentCount: totalStudents,
                    activityCount: totalActivities
                };
            }));

            setTutors(tutorsWithStats);
            setLoading(false);
        });

        // Fetch global class stats
        const fetchGlobalStats = async () => {
            const classesSnap = await getDocs(collection(db, 'classes'));
            let totalStudents = 0;
            let totalActivities = 0;

            classesSnap.docs.forEach(doc => {
                const data = doc.data();
                totalStudents += data.students?.length || 0;
                const units = data.units || [];
                units.forEach(u => {
                    totalActivities += u.games?.length || 0;
                });
            });

            setGlobalStats({
                totalClasses: classesSnap.size,
                totalStudentsInClasses: totalStudents,
                totalActivitiesCreated: totalActivities,
                avgStudentsPerClass: classesSnap.size > 0 ? Math.round(totalStudents / classesSnap.size) : 0
            });
        };

        fetchGlobalStats();
        return () => unsubscribe();
    }, []);

    const handleViewTutor = async (tutor) => {
        setSelectedTutor(tutor);
        // Fetch tutor's classes
        const classesQuery = query(
            collection(db, 'classes'),
            where('tutorId', '==', tutor.id)
        );
        const classesSnap = await getDocs(classesQuery);
        setTutorClasses(classesSnap.docs.map(d => ({ id: d.id, ...d.data() })));
    };

    const handleToggleStatus = async (tutor) => {
        const newStatus = tutor.status === 'active' ? 'suspended' : 'active';
        if (window.confirm(`¿${newStatus === 'suspended' ? 'Suspender' : 'Reactivar'} a ${tutor.name}?`)) {
            await updateDoc(doc(db, 'users', tutor.id), { status: newStatus });
        }
    };

    const handleDelete = async (tutorId) => {
        if (window.confirm('¿Eliminar este tutor? Esta acción no se puede deshacer.')) {
            await deleteDoc(doc(db, 'users', tutorId));
            setSelectedTutor(null);
        }
    };

    const filteredTutors = tutors.filter(t =>
        t.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
        t.email?.toLowerCase().includes(searchTerm.toLowerCase())
    );

    const formatDate = (date) => {
        if (!date) return 'N/A';
        const d = date.toDate ? date.toDate() : new Date(date);
        return d.toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' });
    };

    return (
        <div className="tutors-page">
            {/* Header */}
            <header className="page-header">
                <div className="header-content">
                    <h1>Gestión de Tutores</h1>
                    <p>Administra a los profesores y revisa sus métricas de clases.</p>
                </div>
            </header>

            {/* Global Class Metrics */}
            <section className="metrics-grid">
                <div className="metric-card">
                    <div className="metric-icon subtle">
                        <GraduationCap size={22} />
                    </div>
                    <div className="metric-info">
                        <span className="metric-value">{tutors.length}</span>
                        <span className="metric-label">Tutores Registrados</span>
                    </div>
                </div>
                <div className="metric-card">
                    <div className="metric-icon subtle">
                        <BookOpen size={22} />
                    </div>
                    <div className="metric-info">
                        <span className="metric-value">{globalStats.totalClasses}</span>
                        <span className="metric-label">Clases Creadas</span>
                    </div>
                </div>
                <div className="metric-card">
                    <div className="metric-icon subtle">
                        <Users size={22} />
                    </div>
                    <div className="metric-info">
                        <span className="metric-value">{globalStats.totalStudentsInClasses}</span>
                        <span className="metric-label">Estudiantes en Clases</span>
                    </div>
                </div>
                <div className="metric-card">
                    <div className="metric-icon subtle">
                        <Gamepad2 size={22} />
                    </div>
                    <div className="metric-info">
                        <span className="metric-value">{globalStats.totalActivitiesCreated}</span>
                        <span className="metric-label">Actividades de Clase</span>
                    </div>
                </div>
            </section>

            {/* Search & Filters */}
            <div className="toolbar">
                <div className="search-box">
                    <Search size={18} className="search-icon" />
                    <input
                        type="text"
                        placeholder="Buscar por nombre o correo..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>
                <div className="stats-summary">
                    <span className="summary-item">
                        <Activity size={14} />
                        Promedio: {globalStats.avgStudentsPerClass} estudiantes/clase
                    </span>
                </div>
            </div>

            {/* Tutors Grid */}
            {loading ? (
                <div className="loading-state">
                    <div className="loader"></div>
                    <span>Cargando tutores...</span>
                </div>
            ) : (
                <div className="tutors-grid">
                    <AnimatePresence>
                        {filteredTutors.map((tutor) => (
                            <motion.div
                                key={tutor.id}
                                layout
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, scale: 0.9 }}
                                className={`tutor-card ${tutor.status === 'suspended' ? 'suspended' : ''}`}
                            >
                                <div className="tutor-header">
                                    <div className="tutor-avatar" style={{ background: `linear-gradient(135deg, ${tutor.color || '#6366f1'}, ${tutor.color || '#8b5cf6'}80)` }}>
                                        {tutor.name?.charAt(0).toUpperCase() || 'T'}
                                    </div>
                                    <div className="tutor-info">
                                        <h4>{tutor.name || 'Sin nombre'}</h4>
                                        <span className="tutor-email">{tutor.email}</span>
                                    </div>
                                    <div className="tutor-status">
                                        <span className={`status-badge ${tutor.status || 'active'}`}>
                                            {tutor.status === 'suspended' ? 'Suspendido' : 'Activo'}
                                        </span>
                                    </div>
                                </div>

                                <div className="tutor-stats">
                                    <div className="tutor-stat">
                                        <BookOpen size={16} />
                                        <span className="stat-val">{tutor.classCount}</span>
                                        <span className="stat-lbl">Clases</span>
                                    </div>
                                    <div className="tutor-stat">
                                        <Users size={16} />
                                        <span className="stat-val">{tutor.studentCount}</span>
                                        <span className="stat-lbl">Estudiantes</span>
                                    </div>
                                    <div className="tutor-stat">
                                        <Gamepad2 size={16} />
                                        <span className="stat-val">{tutor.activityCount}</span>
                                        <span className="stat-lbl">Actividades</span>
                                    </div>
                                </div>

                                <div className="tutor-actions">
                                    <button className="action-btn view" onClick={() => handleViewTutor(tutor)}>
                                        <Eye size={16} />
                                        <span>Ver Detalles</span>
                                    </button>
                                    <button
                                        className={`action-btn ${tutor.status === 'suspended' ? 'activate' : 'suspend'}`}
                                        onClick={() => handleToggleStatus(tutor)}
                                    >
                                        {tutor.status === 'suspended' ? <Shield size={16} /> : <ShieldOff size={16} />}
                                    </button>
                                    <button className="action-btn delete" onClick={() => handleDelete(tutor.id)}>
                                        <Trash2 size={16} />
                                    </button>
                                </div>
                            </motion.div>
                        ))}
                    </AnimatePresence>

                    {filteredTutors.length === 0 && !loading && (
                        <div className="empty-state">
                            <GraduationCap size={48} />
                            <h3>No hay tutores registrados</h3>
                            <p>Los tutores se registran automáticamente cuando crean una cuenta desde la app móvil.</p>
                        </div>
                    )}
                </div>
            )}

            {/* Tutor Detail Modal */}
            <AnimatePresence>
                {selectedTutor && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="modal-overlay"
                        onClick={() => setSelectedTutor(null)}
                    >
                        <motion.div
                            initial={{ y: 50, opacity: 0 }}
                            animate={{ y: 0, opacity: 1 }}
                            exit={{ y: 50, opacity: 0 }}
                            className="modal-content tutor-detail-modal"
                            onClick={(e) => e.stopPropagation()}
                        >
                            <div className="modal-header">
                                <div className="tutor-profile">
                                    <div className="large-avatar" style={{ background: `linear-gradient(135deg, ${selectedTutor.color || '#6366f1'}, ${selectedTutor.color || '#8b5cf6'}80)` }}>
                                        {selectedTutor.name?.charAt(0).toUpperCase() || 'T'}
                                    </div>
                                    <div>
                                        <h2>{selectedTutor.name}</h2>
                                        <span className="email">{selectedTutor.email}</span>
                                    </div>
                                </div>
                                <span className={`status-badge large ${selectedTutor.status || 'active'}`}>
                                    {selectedTutor.status === 'suspended' ? 'Suspendido' : 'Activo'}
                                </span>
                            </div>

                            <div className="detail-stats">
                                <div className="detail-stat">
                                    <BookOpen size={20} />
                                    <div>
                                        <span className="val">{selectedTutor.classCount}</span>
                                        <span className="lbl">Clases Creadas</span>
                                    </div>
                                </div>
                                <div className="detail-stat">
                                    <Users size={20} />
                                    <div>
                                        <span className="val">{selectedTutor.studentCount}</span>
                                        <span className="lbl">Total Estudiantes</span>
                                    </div>
                                </div>
                                <div className="detail-stat">
                                    <Gamepad2 size={20} />
                                    <div>
                                        <span className="val">{selectedTutor.activityCount}</span>
                                        <span className="lbl">Actividades</span>
                                    </div>
                                </div>
                            </div>

                            <div className="classes-section">
                                <h3><Layers size={18} /> Clases del Tutor</h3>
                                {tutorClasses.length > 0 ? (
                                    <div className="classes-list">
                                        {tutorClasses.map((cls) => (
                                            <div key={cls.id} className="class-item">
                                                <div className="class-icon" style={{ background: cls.color || '#6366f1' }}>
                                                    <BookOpen size={16} />
                                                </div>
                                                <div className="class-info">
                                                    <span className="class-name">{cls.name}</span>
                                                    <span className="class-code">Código: {cls.classCode}</span>
                                                </div>
                                                <div className="class-stats">
                                                    <span><Users size={12} /> {cls.students?.length || 0}</span>
                                                    <span><Gamepad2 size={12} /> {cls.units?.reduce((a, u) => a + (u.games?.length || 0), 0) || 0}</span>
                                                </div>
                                            </div>
                                        ))}
                                    </div>
                                ) : (
                                    <div className="no-classes">
                                        <p>Este tutor no ha creado clases aún.</p>
                                    </div>
                                )}
                            </div>

                            <div className="modal-footer">
                                <button className="btn" onClick={() => setSelectedTutor(null)}>Cerrar</button>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default TutorsPage;
