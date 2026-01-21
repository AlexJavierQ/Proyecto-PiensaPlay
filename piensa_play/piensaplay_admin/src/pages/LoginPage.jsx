import React, { useState } from 'react';
import { auth, db } from '../firebase';
import { signInWithEmailAndPassword } from 'firebase/auth';
import { doc, getDoc } from 'firebase/firestore';
import { Zap, Mail, Lock, LogIn, AlertCircle, Loader2 } from 'lucide-react';
import { motion } from 'framer-motion';
import './LoginPage.css';

const LoginPage = () => {
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [error, setError] = useState('');
    const [loading, setLoading] = useState(false);

    const handleLogin = async (e) => {
        e.preventDefault();
        setError('');
        setLoading(true);

        try {
            const userCredential = await signInWithEmailAndPassword(auth, email, password);
            const user = userCredential.user;

            // Check if user is admin
            const userDoc = await getDoc(doc(db, 'users', user.uid));
            if (userDoc.exists()) {
                const userData = userDoc.data();
                if (userData.role !== 'admin' && userData.role !== 'superadmin') {
                    await auth.signOut();
                    setError('Acceso denegado. Solo administradores pueden acceder.');
                    setLoading(false);
                    return;
                }
            } else {
                await auth.signOut();
                setError('Usuario no encontrado en el sistema.');
                setLoading(false);
                return;
            }
        } catch (err) {
            console.error('Login error:', err);
            switch (err.code) {
                case 'auth/user-not-found':
                    setError('No existe una cuenta con este correo.');
                    break;
                case 'auth/wrong-password':
                    setError('Contraseña incorrecta.');
                    break;
                case 'auth/invalid-email':
                    setError('Correo electrónico inválido.');
                    break;
                case 'auth/invalid-credential':
                    setError('Credenciales inválidas. Verifica tu correo y contraseña.');
                    break;
                case 'auth/too-many-requests':
                    setError('Demasiados intentos. Intenta más tarde.');
                    break;
                default:
                    setError('Error al iniciar sesión. Verifica tus credenciales.');
            }
            setLoading(false);
        }
    };

    return (
        <div className="login-page">
            <div className="login-background">
                <div className="bg-gradient"></div>
                <div className="bg-pattern"></div>
            </div>

            <motion.div
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.5 }}
                className="login-container"
            >
                <div className="login-header">
                    <div className="login-logo">
                        <div className="logo-icon">
                            <Zap size={32} />
                        </div>
                    </div>
                    <h1>PiensaPlay</h1>
                    <p>Panel de Administración</p>
                </div>

                <form onSubmit={handleLogin} className="login-form">
                    {error && (
                        <motion.div
                            initial={{ opacity: 0, y: -10 }}
                            animate={{ opacity: 1, y: 0 }}
                            className="error-message"
                        >
                            <AlertCircle size={18} />
                            <span>{error}</span>
                        </motion.div>
                    )}

                    <div className="form-group">
                        <label>Correo Electrónico</label>
                        <div className="input-wrapper">
                            <Mail size={18} className="input-icon" />
                            <input
                                type="email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                placeholder="admin@piensaplay.com"
                                required
                                disabled={loading}
                            />
                        </div>
                    </div>

                    <div className="form-group">
                        <label>Contraseña</label>
                        <div className="input-wrapper">
                            <Lock size={18} className="input-icon" />
                            <input
                                type="password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                placeholder="••••••••"
                                required
                                disabled={loading}
                            />
                        </div>
                    </div>

                    <button type="submit" className="login-btn" disabled={loading}>
                        {loading ? (
                            <>
                                <Loader2 size={20} className="spin" />
                                <span>Verificando...</span>
                            </>
                        ) : (
                            <>
                                <LogIn size={20} />
                                <span>Iniciar Sesión</span>
                            </>
                        )}
                    </button>
                </form>

                <div className="login-footer">
                    <p>Acceso exclusivo para administradores autorizados</p>
                </div>
            </motion.div>
        </div>
    );
};

export default LoginPage;
