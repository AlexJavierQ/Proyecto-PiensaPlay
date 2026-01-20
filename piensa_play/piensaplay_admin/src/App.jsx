import React from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import Layout from './layouts/Layout';
import Dashboard from './pages/Dashboard';
import UnitsPage from './pages/UnitsPage';
import AvatarsPage from './pages/AvatarsPage';
import GlossaryPage from './pages/GlossaryPage';
import StudentsPage from './pages/StudentsPage';
import ReportsPage from './pages/ReportsPage';
import SettingsPage from './pages/SettingsPage';

function App() {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<Layout />}>
          <Route index element={<Dashboard />} />
          <Route path="units" element={<UnitsPage />} />
          <Route path="avatars" element={<AvatarsPage />} />
          <Route path="glossary" element={<GlossaryPage />} />
          <Route path="students" element={<StudentsPage />} />
          <Route path="reports" element={<ReportsPage />} />
          <Route path="settings" element={<SettingsPage />} />
          {/* Redirect old routes */}
          <Route path="tutors" element={<Navigate to="/students" replace />} />
          <Route path="users" element={<Navigate to="/students" replace />} />
          <Route path="classes" element={<Navigate to="/" replace />} />
        </Route>
      </Routes>
    </Router>
  );
}

export default App;
