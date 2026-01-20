import React from 'react';
import { NavLink } from 'react-router-dom';
import {
    LayoutDashboard,
    Gamepad2,
    Settings,
    BookOpen,
    LogOut,
    ChevronRight,
    UserCircle,
    BarChart3,
    Users,
    Sparkles,
    Zap
} from 'lucide-react';
import { auth } from '../firebase';
import { signOut } from 'firebase/auth';
import './Sidebar.css';

const Sidebar = () => {
    const handleLogout = () => {
        if (window.confirm('¿Deseas cerrar la sesión?')) {
            signOut(auth).catch(err => console.error(err));
        }
    };

    const menuItems = [
        { icon: LayoutDashboard, label: 'Dashboard', path: '/' },
        { icon: BarChart3, label: 'Analíticas', path: '/reports' },
        { divider: true, label: 'Contenido' },
        { icon: Gamepad2, label: 'Unidades & Juegos', path: '/units' },
        { icon: UserCircle, label: 'Tienda', path: '/avatars' },
        { icon: BookOpen, label: 'Glosario', path: '/glossary' },
        { divider: true, label: 'Comunidad' },
        { icon: Users, label: 'Jugadores', path: '/students' },
        { divider: true, label: 'Sistema' },
        { icon: Settings, label: 'Configuración', path: '/settings' },
    ];

    return (
        <aside className="sidebar">
            <div className="sidebar-header">
                <div className="logo">
                    <div className="logo-icon">
                        <Zap size={24} />
                    </div>
                    <div className="logo-text">
                        <span className="logo-title">PiensaPlay</span>
                        <span className="logo-version">Admin v2.0</span>
                    </div>
                </div>
            </div>

            <nav className="sidebar-nav">
                {menuItems.map((item, index) => {
                    if (item.divider) {
                        return (
                            <div key={index} className="nav-divider">
                                <span>{item.label}</span>
                            </div>
                        );
                    }
                    return (
                        <NavLink
                            key={item.path}
                            to={item.path}
                            className={({ isActive }) => `nav-item ${isActive ? 'active' : ''}`}
                        >
                            <div className="nav-icon-wrapper">
                                <item.icon size={18} className="nav-icon" />
                            </div>
                            <span className="nav-label">{item.label}</span>
                            <ChevronRight className="nav-arrow" size={14} />
                        </NavLink>
                    );
                })}
            </nav>

            <div className="sidebar-footer">
                <div className="admin-info">
                    <div className="admin-avatar">
                        <Sparkles size={16} />
                    </div>
                    <div className="admin-details">
                        <span className="admin-name">Administrador</span>
                        <span className="admin-role">Super Admin</span>
                    </div>
                </div>
                <button className="logout-btn" onClick={handleLogout}>
                    <LogOut size={18} />
                </button>
            </div>
        </aside>
    );
};

export default Sidebar;
