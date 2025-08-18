import React from 'react';
import { Navigate } from 'react-router-dom';

function ProtectedRoute({ children }) {
  const token = localStorage.getItem('jwtToken');

  if (!token) {
    // Jika tidak ada token, arahkan ke halaman login
    return <Navigate to="/login" replace />;
  }

  // Jika ada token, tampilkan komponen yang diminta (misal: DashboardPage)
  return children;
}

export default ProtectedRoute;