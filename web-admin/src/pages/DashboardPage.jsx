import React from 'react';

function DashboardPage() {
  const handleLogout = () => {
    localStorage.removeItem('jwtToken');
    window.location.href = '/login'; // Redirect dan refresh
  };

  return (
    <div className="p-8">
      <h1 className="text-3xl font-bold">Selamat Datang di Dashboard</h1>
      <p className="mt-4">Anda berhasil login sebagai admin.</p>
      <button 
        onClick={handleLogout}
        className="mt-6 bg-red-600 text-white font-bold py-2 px-4 rounded hover:bg-red-700"
      >
        Logout
      </button>
    </div>
  );
}

export default DashboardPage;