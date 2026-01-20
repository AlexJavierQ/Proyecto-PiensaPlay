import React from 'react';
import Sidebar from '../components/Sidebar';
import { Outlet } from 'react-router-dom';
import './Layout.css';

const Layout = () => {
    return (
        <div className="admin-layout">
            <Sidebar />
            <main className="main-content">
                <Outlet />
            </main>
        </div>
    );
};

export default Layout;
