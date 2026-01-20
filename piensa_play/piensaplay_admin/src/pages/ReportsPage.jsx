import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { db } from '../firebase';
import { collection, query, getDocs, where } from 'firebase/firestore';
import {
    BarChart3, Users, Gamepad2, TrendingUp, Award,
    RefreshCw, Star, BookOpen, Target, Activity,
    ArrowUpRight, ArrowDownRight, Zap, Clock, Trophy,
    PieChart, LineChart
} from 'lucide-react';
import { motion } from 'framer-motion';
import './ReportsPage.css';

const ReportsPage = () => {
    const navigate = useNavigate();
    const [stats, setStats] = useState({
        totalPlayers: 0,
        newPlayersWeek: 0,
        activePlayers: 0,
        totalXp: 0,
        avgXp: 0,
        totalUnits: 0,
        totalActivities: 0,
        completionRate: 0,
        engagementRate: 0,
        topPlayers: [],
        activityDistribution: {},
        dailyActive: [],
        retentionRate: 0,
        avgSessionTime: 0
    });
    const [loading, setLoading] = useState(true);
    const [period, setPeriod] = useState('week');

    const fetchAllStats = async () => {
        setLoading(true);
        try {
            const [usersSnap, unitsSnap, glossarySnap] = await Promise.all([
                getDocs(collection(db, 'users')),
                getDocs(query(collection(db, 'game_units'), where('classId', '==', null))),
                getDocs(collection(db, 'glossary'))
            ]);

            const allUsers = usersSnap.docs.map(d => ({ id: d.id, ...d.data() }));
            const players = allUsers.filter(u => !u.role || u.role === 'student');

            const totalXp = players.reduce((acc, s) => acc + (s.totalXp || 0), 0);
            const avgXp = players.length > 0 ? Math.round(totalXp / players.length) : 0;

            const topPlayers = [...players]
                .sort((a, b) => (b.totalXp || 0) - (a.totalXp || 0))
                .slice(0, 8);

            const units = unitsSnap.docs.map(d => ({ id: d.id, ...d.data() }));
            let totalActivities = 0;
            const activityDistribution = {};

            units.forEach(unit => {
                const activities = unit.games || unit.activities || [];
                totalActivities += activities.length;
                activities.forEach(act => {
                    const type = act.type || 'other';
                    activityDistribution[type] = (activityDistribution[type] || 0) + 1;
                });
            });

            // Simulated metrics (in production would come from analytics)
            const activePlayers = Math.floor(players.length * 0.65);
            const newPlayersWeek = Math.floor(players.length * 0.12);
            const completionRate = 76;
            const engagementRate = 82;
            const retentionRate = 68;
            const avgSessionTime = 12;

            setStats({
                totalPlayers: players.length,
                newPlayersWeek,
                activePlayers,
                totalXp,
                avgXp,
                totalUnits: units.length,
                totalActivities,
                completionRate,
                engagementRate,
                topPlayers,
                activityDistribution,
                retentionRate,
                avgSessionTime
            });

        } catch (error) {
            console.error("Error fetching stats:", error);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchAllStats();
    }, [period]);

    const kpiCards = [
        {
            label: 'Jugadores Totales',
            value: stats.totalPlayers,
            change: '+12%',
            trend: 'up',
            icon: Users,
            color: 'var(--primary)'
        },
        {
            label: 'Nuevos esta semana',
            value: stats.newPlayersWeek,
            change: '+8%',
            trend: 'up',
            icon: TrendingUp,
            color: 'var(--accent)'
        },
        {
            label: 'Jugadores Activos',
            value: stats.activePlayers,
            change: '+5%',
            trend: 'up',
            icon: Activity,
            color: 'var(--secondary)'
        },
        {
            label: 'Tasa Retención',
            value: `${stats.retentionRate}%`,
            change: '+3%',
            trend: 'up',
            icon: Target,
            color: 'var(--purple)'
        },
    ];

    const performanceMetrics = [
        { label: 'Tasa de Completado', value: stats.completionRate, max: 100, color: 'var(--accent)' },
        { label: 'Engagement', value: stats.engagementRate, max: 100, color: 'var(--primary)' },
        { label: 'Retención', value: stats.retentionRate, max: 100, color: 'var(--purple)' },
    ];

    const activityTypeLabels = {
        quiz: { label: 'Quiz', emoji: '🎯', color: 'var(--primary)' },
        memory: { label: 'Memoria', emoji: '🧠', color: 'var(--purple)' },
        match_pairs: { label: 'Emparejar', emoji: '🔗', color: 'var(--accent)' },
        order_sequence: { label: 'Ordenar', emoji: '📋', color: 'var(--secondary)' },
        fill_blanks: { label: 'Completar', emoji: '✏️', color: 'var(--orange)' },
        word_selection: { label: 'Sendero', emoji: '🛤️', color: 'var(--warning)' },
        fake_news: { label: 'Fake News', emoji: '📰', color: 'var(--pink)' },
        stereotype_breaker: { label: 'Estereotipos', emoji: '🌈', color: 'var(--cyan)' },
        other: { label: 'Otros', emoji: '🎮', color: 'var(--text-muted)' }
    };

    return (
        <div className="reports-page">
            <header className="page-header">
                <div className="header-content">
                    <h1>Analíticas</h1>
                    <p>Métricas de rendimiento y engagement de la plataforma</p>
                </div>
                <div className="header-actions">
                    <div className="period-selector">
                        {['day', 'week', 'month', 'year'].map(p => (
                            <button
                                key={p}
                                className={`period-btn ${period === p ? 'active' : ''}`}
                                onClick={() => setPeriod(p)}
                            >
                                {p === 'day' ? 'Hoy' : p === 'week' ? 'Semana' : p === 'month' ? 'Mes' : 'Año'}
                            </button>
                        ))}
                    </div>
                    <button className="btn btn-secondary" onClick={fetchAllStats} disabled={loading}>
                        <RefreshCw size={16} className={loading ? 'spinning' : ''} />
                        Actualizar
                    </button>
                </div>
            </header>

            {/* KPI Cards */}
            <motion.section
                className="kpi-grid"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
            >
                {kpiCards.map((kpi, index) => (
                    <motion.div
                        key={index}
                        className="kpi-card"
                        initial={{ opacity: 0, y: 20 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: index * 0.1 }}
                    >
                        <div className="kpi-header">
                            <div className="kpi-icon" style={{ color: kpi.color, background: `${kpi.color}15` }}>
                                <kpi.icon size={20} />
                            </div>
                            <div className={`kpi-change ${kpi.trend}`}>
                                {kpi.trend === 'up' ? <ArrowUpRight size={14} /> : <ArrowDownRight size={14} />}
                                {kpi.change}
                            </div>
                        </div>
                        <div className="kpi-value">{loading ? '...' : kpi.value.toLocaleString()}</div>
                        <div className="kpi-label">{kpi.label}</div>
                    </motion.div>
                ))}
            </motion.section>

            {/* XP Overview */}
            <motion.section
                className="xp-overview-section"
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: 0.3 }}
            >
                <div className="xp-overview-card">
                    <div className="xp-main">
                        <div className="xp-icon">
                            <Zap size={32} />
                        </div>
                        <div className="xp-data">
                            <span className="xp-total">{stats.totalXp.toLocaleString()}</span>
                            <span className="xp-label">XP Total Generado</span>
                        </div>
                    </div>
                    <div className="xp-divider"></div>
                    <div className="xp-secondary">
                        <div className="xp-stat">
                            <Trophy size={18} />
                            <span className="value">{stats.avgXp.toLocaleString()}</span>
                            <span className="label">Promedio por jugador</span>
                        </div>
                        <div className="xp-stat">
                            <Clock size={18} />
                            <span className="value">{stats.avgSessionTime} min</span>
                            <span className="label">Sesión promedio</span>
                        </div>
                    </div>
                </div>
            </motion.section>

            <div className="reports-grid">
                {/* Performance Metrics */}
                <motion.div
                    className="card metrics-card"
                    initial={{ opacity: 0, x: -20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.4 }}
                >
                    <div className="card-header">
                        <h3><BarChart3 size={18} /> Métricas de Rendimiento</h3>
                    </div>
                    <div className="metrics-list">
                        {performanceMetrics.map((metric, idx) => (
                            <div key={idx} className="metric-row">
                                <div className="metric-info">
                                    <span className="metric-name">{metric.label}</span>
                                    <span className="metric-value" style={{ color: metric.color }}>{metric.value}%</span>
                                </div>
                                <div className="metric-bar-wrapper">
                                    <div
                                        className="metric-bar-fill"
                                        style={{
                                            width: `${metric.value}%`,
                                            background: `linear-gradient(90deg, ${metric.color}, ${metric.color}80)`
                                        }}
                                    ></div>
                                </div>
                            </div>
                        ))}
                    </div>
                </motion.div>

                {/* Activity Distribution */}
                <motion.div
                    className="card distribution-card"
                    initial={{ opacity: 0, x: 20 }}
                    animate={{ opacity: 1, x: 0 }}
                    transition={{ delay: 0.5 }}
                >
                    <div className="card-header">
                        <h3><PieChart size={18} /> Distribución de Actividades</h3>
                        <span className="badge">{stats.totalActivities} total</span>
                    </div>
                    <div className="distribution-list">
                        {Object.entries(stats.activityDistribution).length > 0 ? (
                            Object.entries(stats.activityDistribution)
                                .sort((a, b) => b[1] - a[1])
                                .map(([type, count]) => {
                                    const info = activityTypeLabels[type] || activityTypeLabels.other;
                                    const percentage = Math.round((count / stats.totalActivities) * 100);
                                    return (
                                        <div key={type} className="distribution-item">
                                            <div className="dist-icon">{info.emoji}</div>
                                            <div className="dist-info">
                                                <span className="dist-name">{info.label}</span>
                                                <div className="dist-bar">
                                                    <div
                                                        className="dist-fill"
                                                        style={{ width: `${percentage}%`, background: info.color }}
                                                    ></div>
                                                </div>
                                            </div>
                                            <span className="dist-count">{count}</span>
                                        </div>
                                    );
                                })
                        ) : (
                            <div className="empty-distribution">No hay actividades configuradas</div>
                        )}
                    </div>
                </motion.div>

                {/* Top Players */}
                <motion.div
                    className="card leaderboard-card"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.6 }}
                >
                    <div className="card-header">
                        <h3><Award size={18} /> Top Jugadores</h3>
                        <button className="btn-ghost" onClick={() => navigate('/students')}>Ver todos</button>
                    </div>
                    <div className="leaderboard-list">
                        {stats.topPlayers.map((player, index) => (
                            <div key={player.id} className="leaderboard-item">
                                <div className={`rank-badge rank-${index + 1}`}>
                                    {index < 3 ? ['🥇', '🥈', '🥉'][index] : index + 1}
                                </div>
                                <div className="player-avatar-mini"
                                    style={{
                                        background: `linear-gradient(135deg, hsl(${(player.avatarIndex || index) * 40 + 200}, 70%, 50%), hsl(${(player.avatarIndex || index) * 40 + 240}, 70%, 40%))`
                                    }}>
                                    {player.name?.charAt(0) || '?'}
                                </div>
                                <div className="player-data">
                                    <span className="player-name">{player.name || 'Anónimo'}</span>
                                    <span className="player-tag">#{player.tag || '------'}</span>
                                </div>
                                <div className="player-xp">
                                    <Star size={14} />
                                    {(player.totalXp || 0).toLocaleString()}
                                </div>
                            </div>
                        ))}
                        {stats.topPlayers.length === 0 && (
                            <div className="empty-leaderboard">No hay jugadores aún</div>
                        )}
                    </div>
                </motion.div>

                {/* Content Stats */}
                <motion.div
                    className="card content-stats-card"
                    initial={{ opacity: 0, y: 20 }}
                    animate={{ opacity: 1, y: 0 }}
                    transition={{ delay: 0.7 }}
                >
                    <div className="card-header">
                        <h3><Gamepad2 size={18} /> Contenido de la Plataforma</h3>
                    </div>
                    <div className="content-stats-grid">
                        <div className="content-stat" onClick={() => navigate('/units')}>
                            <div className="content-stat-icon" style={{ background: 'linear-gradient(135deg, var(--warning), var(--orange))' }}>
                                <Gamepad2 size={24} />
                            </div>
                            <div className="content-stat-value">{stats.totalUnits}</div>
                            <div className="content-stat-label">Unidades</div>
                        </div>
                        <div className="content-stat" onClick={() => navigate('/units')}>
                            <div className="content-stat-icon" style={{ background: 'linear-gradient(135deg, var(--accent), var(--cyan))' }}>
                                <Activity size={24} />
                            </div>
                            <div className="content-stat-value">{stats.totalActivities}</div>
                            <div className="content-stat-label">Actividades</div>
                        </div>
                        <div className="content-stat" onClick={() => navigate('/glossary')}>
                            <div className="content-stat-icon" style={{ background: 'linear-gradient(135deg, var(--pink), var(--purple))' }}>
                                <BookOpen size={24} />
                            </div>
                            <div className="content-stat-value">{stats.totalPlayers}</div>
                            <div className="content-stat-label">Jugadores</div>
                        </div>
                    </div>
                </motion.div>
            </div>
        </div>
    );
};

export default ReportsPage;
