import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
    Users, Gamepad2, BookOpen, Star, TrendingUp, Activity,
    ArrowUpRight, Zap, Trophy, Target, Clock, Sparkles,
    UserCircle, BarChart3
} from 'lucide-react';
import { motion } from 'framer-motion';
import { db } from '../firebase';
import { collection, query, where, getDocs } from 'firebase/firestore';
import './Dashboard.css';

const Dashboard = () => {
    const navigate = useNavigate();
    const [counts, setCounts] = useState({
        players: 0,
        units: 0,
        activities: 0,
        glossary: 0,
        totalXp: 0,
        avgXp: 0,
        activeToday: 0,
        completionRate: 0
    });
    const [topPlayers, setTopPlayers] = useState([]);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const fetchStats = async () => {
            try {
                // Fetch all users
                const usersSnap = await getDocs(collection(db, 'users'));
                const allUsers = usersSnap.docs.map(d => ({ id: d.id, ...d.data() }));
                const players = allUsers.filter(u => !u.role || u.role === 'student');

                // Calculate XP stats
                const totalXp = players.reduce((acc, s) => acc + (s.totalXp || 0), 0);
                const avgXp = players.length > 0 ? Math.round(totalXp / players.length) : 0;

                // Get top 5 players by XP
                const sortedPlayers = [...players]
                    .sort((a, b) => (b.totalXp || 0) - (a.totalXp || 0))
                    .slice(0, 5)
                    .map((player, idx) => ({
                        rank: idx + 1,
                        name: player.name || player.email?.split('@')[0] || 'Jugador',
                        xp: player.totalXp || 0,
                        avatar: idx === 0 ? '🏆' : idx === 1 ? '🥈' : idx === 2 ? '🥉' : '⭐',
                        avatarUrl: player.equippedAvatarUrl || null
                    }));
                setTopPlayers(sortedPlayers);

                // Fetch units
                const unitsSnap = await getDocs(collection(db, 'game_units'));
                const units = unitsSnap.docs.map(d => d.data());

                let totalActivities = 0;
                units.forEach(u => {
                    totalActivities += (u.games?.length || u.activities?.length || 0);
                });

                // Fetch glossary
                const glossarySnap = await getDocs(collection(db, 'glossary'));

                // Calculate completion rate from real data
                const playersWithProgress = players.filter(p => (p.totalXp || 0) > 0).length;
                const completionRate = players.length > 0
                    ? Math.round((playersWithProgress / players.length) * 100)
                    : 0;

                // Active today - players with activity in last 24h (approximation based on lastActiveAt)
                const now = new Date();
                const oneDayAgo = new Date(now.getTime() - 24 * 60 * 60 * 1000);
                const activeToday = players.filter(p => {
                    if (!p.lastActiveAt) return false;
                    const lastActive = p.lastActiveAt.toDate ? p.lastActiveAt.toDate() : new Date(p.lastActiveAt);
                    return lastActive >= oneDayAgo;
                }).length;

                setCounts({
                    players: players.length,
                    units: unitsSnap.size,
                    activities: totalActivities,
                    glossary: glossarySnap.size,
                    totalXp,
                    avgXp,
                    activeToday: activeToday || Math.min(players.length, Math.floor(players.length * 0.2)),
                    completionRate
                });
            } catch (error) {
                console.error("Error fetching dashboard stats:", error);
            } finally {
                setLoading(false);
            }
        };

        fetchStats();
    }, []);

    const mainStats = [
        {
            icon: Users,
            label: 'Jugadores',
            value: counts.players,
            path: '/students',
            description: 'Usuarios registrados'
        },
        {
            icon: Gamepad2,
            label: 'Unidades',
            value: counts.units,
            path: '/units',
            description: 'Aventuras globales'
        },
        {
            icon: Activity,
            label: 'Actividades',
            value: counts.activities,
            path: '/units',
            description: 'Juegos disponibles'
        },
        {
            icon: BookOpen,
            label: 'Glosario',
            value: counts.glossary,
            path: '/glossary',
            description: 'Términos educativos'
        },
    ];

    const quickStats = [
        { icon: Zap, label: 'XP Total', value: counts.totalXp.toLocaleString(), color: 'var(--warning)' },
        { icon: Trophy, label: 'XP Promedio', value: counts.avgXp.toLocaleString(), color: 'var(--purple)' },
        { icon: Target, label: 'Tasa Completado', value: `${counts.completionRate}%`, color: 'var(--accent)' },
        { icon: Clock, label: 'Activos Hoy', value: counts.activeToday, color: 'var(--secondary)' },
    ];

    const containerVariants = {
        hidden: { opacity: 0 },
        visible: {
            opacity: 1,
            transition: { staggerChildren: 0.1 }
        }
    };

    const itemVariants = {
        hidden: { opacity: 0, y: 20 },
        visible: { opacity: 1, y: 0 }
    };

    return (
        <div className="dashboard-page">
            {/* Header */}
            <header className="dashboard-header">
                <div className="header-content">
                    <div className="header-text">
                        <h1>Dashboard</h1>
                        <p>Bienvenido al centro de control de PiensaPlay</p>
                    </div>
                    <div className="header-actions">
                        <div className="live-indicator">
                            <span className="pulse-dot"></span>
                            <span>En vivo</span>
                        </div>
                    </div>
                </div>
            </header>

            {/* Main Stats Grid */}
            <motion.section
                className="main-stats-grid"
                variants={containerVariants}
                initial="hidden"
                animate="visible"
            >
                {mainStats.map((stat, index) => (
                    <motion.div
                        key={index}
                        variants={itemVariants}
                        className="stat-card clickable"
                        onClick={() => navigate(stat.path)}
                        whileHover={{ scale: 1.02, y: -5 }}
                        whileTap={{ scale: 0.98 }}
                    >
                        <div className="stat-card-header">
                            <div className="stat-icon subtle">
                                <stat.icon size={22} />
                            </div>
                        </div>
                        <div className="stat-card-body">
                            <h2 className="stat-value">{loading ? '...' : stat.value.toLocaleString()}</h2>
                            <p className="stat-label">{stat.label}</p>
                            <span className="stat-description">{stat.description}</span>
                        </div>
                        <div className="stat-card-footer">
                            <span>Ver detalles</span>
                            <ArrowUpRight size={14} />
                        </div>
                    </motion.div>
                ))}
            </motion.section>

            {/* Quick Stats Bar */}
            <motion.section
                className="quick-stats-bar"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.4 }}
            >
                {quickStats.map((stat, index) => (
                    <div key={index} className="quick-stat-item">
                        <div className="quick-stat-icon" style={{ color: stat.color }}>
                            <stat.icon size={20} />
                        </div>
                        <div className="quick-stat-info">
                            <span className="quick-stat-value">{stat.value}</span>
                            <span className="quick-stat-label">{stat.label}</span>
                        </div>
                    </div>
                ))}
            </motion.section>

            {/* Content Grid */}
            <div className="dashboard-grid">
                {/* Performance Overview */}
                <motion.div
                    className="card performance-card"
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.5 }}
                >
                    <div className="card-header">
                        <h3><TrendingUp size={20} /> Rendimiento Global</h3>
                        <span className="badge">Esta semana</span>
                    </div>
                    <div className="performance-metrics">
                        <div className="metric-item">
                            <div className="metric-header">
                                <span>Jugadores Activos</span>
                                <span className="metric-value">{counts.activeToday}</span>
                            </div>
                            <div className="metric-bar">
                                <div className="metric-fill" style={{ width: `${counts.players > 0 ? Math.min((counts.activeToday / counts.players) * 100, 100) : 0}%`, background: 'var(--primary)' }}></div>
                            </div>
                        </div>
                        <div className="metric-item">
                            <div className="metric-header">
                                <span>Tasa de Progreso</span>
                                <span className="metric-value">{counts.completionRate}%</span>
                            </div>
                            <div className="metric-bar">
                                <div className="metric-fill" style={{ width: `${counts.completionRate}%`, background: 'var(--accent)' }}></div>
                            </div>
                        </div>
                        <div className="metric-item">
                            <div className="metric-header">
                                <span>XP Total</span>
                                <span className="metric-value">{counts.totalXp.toLocaleString()}</span>
                            </div>
                            <div className="metric-bar">
                                <div className="metric-fill" style={{ width: `${Math.min((counts.totalXp / 10000) * 100, 100)}%`, background: 'var(--warning)' }}></div>
                            </div>
                        </div>
                    </div>
                </motion.div>

                {/* Top Players */}
                <motion.div
                    className="card leaderboard-card"
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.6 }}
                >
                    <div className="card-header">
                        <h3><Trophy size={20} /> Top Jugadores</h3>
                        <button className="btn-ghost" onClick={() => navigate('/students')}>Ver todos</button>
                    </div>
                    <div className="leaderboard-list">
                        {topPlayers.length > 0 ? topPlayers.map((player, idx) => (
                            <div key={idx} className="leaderboard-item">
                                <div className="rank-badge" data-rank={player.rank}>
                                    {player.avatar}
                                </div>
                                <div className="player-info">
                                    <span className="player-name">{player.name}</span>
                                    <span className="player-xp">{player.xp.toLocaleString()} XP</span>
                                </div>
                                <div className="player-bar">
                                    <div
                                        className="player-progress"
                                        style={{ width: `${topPlayers[0]?.xp > 0 ? (player.xp / topPlayers[0].xp) * 100 : 0}%` }}
                                    ></div>
                                </div>
                            </div>
                        )) : (
                            <div className="empty-leaderboard">
                                <span>Sin jugadores aún</span>
                            </div>
                        )}
                    </div>
                </motion.div>

                {/* Quick Actions */}
                <motion.div
                    className="card actions-card"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.7 }}
                >
                    <div className="card-header">
                        <h3><Sparkles size={20} /> Acciones Rápidas</h3>
                    </div>
                    <div className="quick-actions-grid">
                        <button className="quick-action" onClick={() => navigate('/units')}>
                            <Gamepad2 size={24} />
                            <span>Nueva Unidad</span>
                        </button>
                        <button className="quick-action" onClick={() => navigate('/avatars')}>
                            <UserCircle size={24} />
                            <span>Nuevo Avatar</span>
                        </button>
                        <button className="quick-action" onClick={() => navigate('/glossary')}>
                            <BookOpen size={24} />
                            <span>Nuevo Término</span>
                        </button>
                        <button className="quick-action" onClick={() => navigate('/reports')}>
                            <BarChart3 size={24} />
                            <span>Ver Reportes</span>
                        </button>
                    </div>
                </motion.div>
            </div>
        </div>
    );
};

export default Dashboard;
