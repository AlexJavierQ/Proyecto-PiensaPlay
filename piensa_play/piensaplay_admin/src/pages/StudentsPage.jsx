import React, { useState, useEffect } from 'react';
import { db } from '../firebase';
import { collection, query, onSnapshot, deleteDoc, doc, updateDoc } from 'firebase/firestore';
import { Users, Search, Star, Trash2, Eye, RefreshCw, Coins, Calendar, MoreHorizontal, Filter, Download } from 'lucide-react';
import { motion, AnimatePresence } from 'framer-motion';
import './StudentsPage.css';

const StudentsPage = () => {
    const [players, setPlayers] = useState([]);
    const [loading, setLoading] = useState(true);
    const [searchTerm, setSearchTerm] = useState('');
    const [selectedPlayer, setSelectedPlayer] = useState(null);
    const [showModal, setShowModal] = useState(false);
    const [sortBy, setSortBy] = useState('xp');

    useEffect(() => {
        const q = query(collection(db, 'users'));
        const unsubscribe = onSnapshot(q, (snapshot) => {
            const playersData = snapshot.docs
                .map(doc => ({ id: doc.id, ...doc.data() }))
                .filter(u => !u.role || u.role === 'student');
            setPlayers(playersData);
            setLoading(false);
        });
        return () => unsubscribe();
    }, []);

    const handleDelete = async (id) => {
        if (window.confirm('¿Estás seguro de eliminar este jugador? Se perderá todo su progreso.')) {
            try {
                await deleteDoc(doc(db, 'users', id));
            } catch (error) {
                console.error("Error deleting player: ", error);
            }
        }
    };

    const handleResetProgress = async (id) => {
        if (window.confirm('¿Resetear todo el progreso de este jugador?')) {
            try {
                await updateDoc(doc(db, 'users', id), {
                    totalXp: 0,
                    walletBalance: 100,
                    purchasedItems: [],
                    equipped_avatar: null,
                    equipped_frame: null,
                    equipped_theme: null
                });
                alert('Progreso reseteado correctamente');
            } catch (error) {
                console.error("Error resetting progress: ", error);
            }
        }
    };

    const filteredPlayers = players
        .filter(s =>
            s.name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
            s.tag?.includes(searchTerm)
        )
        .sort((a, b) => {
            if (sortBy === 'xp') return (b.totalXp || 0) - (a.totalXp || 0);
            if (sortBy === 'coins') return (b.walletBalance || 0) - (a.walletBalance || 0);
            if (sortBy === 'name') return (a.name || '').localeCompare(b.name || '');
            return 0;
        });

    const formatDate = (timestamp) => {
        if (!timestamp) return 'N/A';
        const date = timestamp.toDate ? timestamp.toDate() : new Date(timestamp);
        return date.toLocaleDateString('es-ES', { day: '2-digit', month: 'short', year: 'numeric' });
    };

    const totalXp = players.reduce((acc, p) => acc + (p.totalXp || 0), 0);
    const totalCoins = players.reduce((acc, p) => acc + (p.walletBalance || 0), 0);

    return (
        <div className="players-page">
            <header className="page-header">
                <div className="header-content">
                    <h1>Jugadores</h1>
                    <p>Gestiona todos los jugadores registrados en la plataforma</p>
                </div>
                <div className="header-stats">
                    <div className="stat-chip">
                        <Users size={16} />
                        <span>{players.length} jugadores</span>
                    </div>
                    <div className="stat-chip gold">
                        <Star size={16} />
                        <span>{totalXp.toLocaleString()} XP total</span>
                    </div>
                    <div className="stat-chip blue">
                        <Coins size={16} />
                        <span>{totalCoins.toLocaleString()} monedas</span>
                    </div>
                </div>
            </header>

            {/* Toolbar */}
            <div className="toolbar">
                <div className="search-box">
                    <Search size={18} className="search-icon" />
                    <input
                        type="text"
                        placeholder="Buscar por nombre o TAG..."
                        value={searchTerm}
                        onChange={(e) => setSearchTerm(e.target.value)}
                    />
                </div>
                <div className="toolbar-actions">
                    <select
                        value={sortBy}
                        onChange={(e) => setSortBy(e.target.value)}
                        className="sort-select"
                    >
                        <option value="xp">Ordenar por XP</option>
                        <option value="coins">Ordenar por Monedas</option>
                        <option value="name">Ordenar por Nombre</option>
                    </select>
                </div>
            </div>

            {loading ? (
                <div className="loading-state">
                    <div className="loader"></div>
                    <span>Cargando jugadores...</span>
                </div>
            ) : (
                <div className="players-grid">
                    <AnimatePresence>
                        {filteredPlayers.map((player, index) => (
                            <motion.div
                                key={player.id}
                                initial={{ opacity: 0, y: 20 }}
                                animate={{ opacity: 1, y: 0 }}
                                exit={{ opacity: 0, scale: 0.9 }}
                                transition={{ delay: index * 0.03 }}
                                className="player-card"
                            >
                                <div className="player-header">
                                    <div
                                        className="player-avatar"
                                        style={{
                                            background: `linear-gradient(135deg, hsl(${(player.avatarIndex || 0) * 40 + 200}, 70%, 50%), hsl(${(player.avatarIndex || 0) * 40 + 240}, 70%, 40%))`
                                        }}
                                    >
                                        {player.name?.charAt(0).toUpperCase() || '?'}
                                    </div>
                                    <div className="player-info">
                                        <h4>{player.name || 'Sin nombre'}</h4>
                                        <span className="player-tag">#{player.tag || '------'}</span>
                                    </div>
                                    <button className="menu-btn" onClick={() => { setSelectedPlayer(player); setShowModal(true); }}>
                                        <MoreHorizontal size={18} />
                                    </button>
                                </div>

                                <div className="player-stats">
                                    <div className="player-stat">
                                        <Star size={16} className="stat-icon gold" />
                                        <div className="stat-data">
                                            <span className="stat-value">{(player.totalXp || 0).toLocaleString()}</span>
                                            <span className="stat-label">XP</span>
                                        </div>
                                    </div>
                                    <div className="player-stat">
                                        <Coins size={16} className="stat-icon blue" />
                                        <div className="stat-data">
                                            <span className="stat-value">{(player.walletBalance || 0).toLocaleString()}</span>
                                            <span className="stat-label">Monedas</span>
                                        </div>
                                    </div>
                                </div>

                                <div className="player-footer">
                                    <span className="player-age">{player.age ? `${player.age} años` : 'Edad N/A'}</span>
                                    <div className="player-actions">
                                        <button className="action-btn view" onClick={() => { setSelectedPlayer(player); setShowModal(true); }}>
                                            <Eye size={14} />
                                        </button>
                                        <button className="action-btn reset" onClick={() => handleResetProgress(player.id)}>
                                            <RefreshCw size={14} />
                                        </button>
                                        <button className="action-btn delete" onClick={() => handleDelete(player.id)}>
                                            <Trash2 size={14} />
                                        </button>
                                    </div>
                                </div>
                            </motion.div>
                        ))}
                    </AnimatePresence>

                    {filteredPlayers.length === 0 && (
                        <div className="empty-state">
                            <Users size={48} />
                            <h3>No se encontraron jugadores</h3>
                            <p>Intenta con otro término de búsqueda</p>
                        </div>
                    )}
                </div>
            )}

            {/* Detail Modal */}
            <AnimatePresence>
                {showModal && selectedPlayer && (
                    <motion.div
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        exit={{ opacity: 0 }}
                        className="modal-overlay"
                        onClick={() => setShowModal(false)}
                    >
                        <motion.div
                            initial={{ scale: 0.9, opacity: 0 }}
                            animate={{ scale: 1, opacity: 1 }}
                            exit={{ scale: 0.9, opacity: 0 }}
                            className="modal-content player-modal"
                            onClick={e => e.stopPropagation()}
                        >
                            <div className="modal-header">
                                <div
                                    className="modal-avatar"
                                    style={{
                                        background: `linear-gradient(135deg, hsl(${(selectedPlayer.avatarIndex || 0) * 40 + 200}, 70%, 50%), hsl(${(selectedPlayer.avatarIndex || 0) * 40 + 240}, 70%, 40%))`
                                    }}
                                >
                                    {selectedPlayer.name?.charAt(0).toUpperCase() || '?'}
                                </div>
                                <div>
                                    <h2>{selectedPlayer.name}</h2>
                                    <span className="modal-tag">#{selectedPlayer.tag}</span>
                                </div>
                            </div>

                            <div className="modal-stats">
                                <div className="modal-stat">
                                    <Star size={20} />
                                    <span className="modal-stat-value">{(selectedPlayer.totalXp || 0).toLocaleString()}</span>
                                    <span className="modal-stat-label">XP Total</span>
                                </div>
                                <div className="modal-stat">
                                    <Coins size={20} />
                                    <span className="modal-stat-value">{(selectedPlayer.walletBalance || 0).toLocaleString()}</span>
                                    <span className="modal-stat-label">Monedas</span>
                                </div>
                            </div>

                            <div className="modal-details">
                                <div className="detail-row">
                                    <span className="detail-label">Edad</span>
                                    <span className="detail-value">{selectedPlayer.age || 'N/A'} años</span>
                                </div>
                                <div className="detail-row">
                                    <span className="detail-label">Items Comprados</span>
                                    <span className="detail-value">{selectedPlayer.purchasedItems?.length || 0}</span>
                                </div>
                                <div className="detail-row">
                                    <span className="detail-label">Avatar Equipado</span>
                                    <span className="detail-value">{selectedPlayer.equipped_avatar || 'Ninguno'}</span>
                                </div>
                            </div>

                            <div className="modal-actions">
                                <button className="btn btn-secondary" onClick={() => setShowModal(false)}>
                                    Cerrar
                                </button>
                                <button className="btn btn-danger" onClick={() => { handleDelete(selectedPlayer.id); setShowModal(false); }}>
                                    <Trash2 size={16} /> Eliminar
                                </button>
                            </div>
                        </motion.div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
};

export default StudentsPage;
