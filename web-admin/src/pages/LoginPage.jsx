import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';

import ScanLogo from '../assets/logo-app.svg?react';

function LoginPage() {
  const [employeeId, setEmployeeId] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const navigate = useNavigate();

  const handleLogin = async (e) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    try {
      // kirim data ke endpoint
      const response = await axios.post(
        'http://35.219.66.90/admin/login',
        { employee_id: employeeId, password }
      );

      // Jika berhasil, simpan token dan navigasi
      const { token } = response.data;
       localStorage.setItem('jwtToken', token);

      // logika rememberme
      if (rememberMe) {
        localStorage.setItem('rememberMe', 'true');
        localStorage.setItem('employeeId', employeeId);
      } else {
        localStorage.removeItem('rememberMe');
        localStorage.removeItem('employeeId');
      }
      
      navigate('/dashboard');

    } catch (err) {
      // Menangkap dan menampilkan pesan error dari backend
      const message = err.response 
        ? err.response.data.message   
        : 'Tidak dapat terhubung ke server. Periksa koneksi Anda.';
      setError(message);
    } finally {
      setIsLoading(false);
    }
  };

  // useEffect untuk mengambil employeeId dari localStorage
  useEffect(() => {
    const remembered = localStorage.getItem('rememberMe');
    if (remembered === 'true') {
      const savedEmployeeId = localStorage.getItem('employeeId');
      if (savedEmployeeId) {
        setEmployeeId(savedEmployeeId);
        setRememberMe(true);
      }
    }
  }, []);

  const togglePasswordVisibility = () => {
    setShowPassword(!showPassword);
  };

  // komponen ikon mata
  const EyeIcon = () => (
    <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" />
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z" />
    </svg>
  );

  const EyeSlashIcon = () => (
    <svg className="h-5 w-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.543-7a9.97 9.97 0 011.563-3.029m5.858.908a3 3 0 114.243 4.243M9.878 9.878l4.242 4.242M9.878 9.878L3 3m6.878 6.878L21 21" />
    </svg>
  );

  return (
    <div className="bg-gradient-to-br from-gray-50 to-gray-200 min-h-screen w-screen flex flex-col justify-center items-center font-sans p-4">
      
      {/* Logo */}
      <div className="flex justify-center mb-6 sm:mb-8">
        <ScanLogo className="h-14 sm:h-16 w-auto text-red-600" />
      </div>

      {/* Login card */}
      <div className="bg-white p-6 sm:p-10 rounded-2xl shadow-xl w-full max-w-md border border-gray-200">

        {/* Header */}
        <div className="text-center mb-8">
          <h2 className="text-2xl sm:text-3xl font-bold text-gray-900 mb-2">Masuk</h2>
        </div>

        {/* Form Login */}
        <form onSubmit={handleLogin} className="space-y-5 sm:space-y-6">
          
          <div>
            <label htmlFor="employee_id" className="block text-sm font-semibold text-gray-700 mb-2">
              Employee ID
            </label>
            <input
              id="employee_id"
              name="employee_id"
              type="text"
              required
              value={employeeId}
              onChange={(e) => setEmployeeId(e.target.value)}
              className="block w-full px-4 py-3 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-200"
              placeholder="Masukkan Employee ID Anda"
              disabled={isLoading}
            />
          </div>

          {/* Input Password */}
          <div>
            <label htmlFor="password" className="block text-sm font-semibold text-gray-700 mb-2">
              Password
            </label>
            <div className="relative">
              <input
                id="password"
                name="password"
                type={showPassword ? "text" : "password"}
                required
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="block w-full px-4 py-3 pr-12 border border-gray-300 rounded-lg shadow-sm placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-red-500 transition-all duration-200"
                placeholder="Masukkan password Anda"
                disabled={isLoading}
              />
              <button
                type="button"
                onClick={togglePasswordVisibility}
                className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 transition-colors duration-200 rounded-full p-1 focus:outline-none focus:ring-2 focus:ring-red-500"
                disabled={isLoading}
              >
                {showPassword ? <EyeSlashIcon /> : <EyeIcon />}
              </button>
            </div>
          </div>

          {/* Remember Me & Lupa Password */}
          <div className="flex items-center justify-between text-sm">
            <div className="flex items-center">
              <input
                id="remember-me"
                name="remember-me"
                type="checkbox"
                checked={rememberMe}
                onChange={(e) => setRememberMe(e.target.checked)}
                className="h-4 w-4 rounded border-gray-300 text-red-600 focus:ring-red-500"
                disabled={isLoading}
              />
              <label htmlFor="remember-me" className="ml-2 block text-gray-700">
                Ingat saya
              </label>
            </div>
            <div>
              <a href="#" className="font-medium text-red-600 hover:text-red-700 transition-colors duration-200 rounded focus:outline-none focus:ring-2 focus:ring-red-500">
                Lupa password?
              </a>
            </div>
          </div>

          {/* Pesan Error */}
          {error && (
            <div className="bg-red-50 border border-red-200 rounded-lg p-3">
              <p className="text-sm text-red-600 text-center font-medium">{error}</p>
            </div>
          )}

          {/* Tombol Login */}
          <div>
            <button
              type="submit"
              disabled={isLoading}
              className="w-full flex justify-center items-center py-3 px-4 border border-transparent rounded-lg shadow-sm text-lg font-semibold text-white bg-red-600 hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition-all duration-300 disabled:opacity-70 disabled:cursor-not-allowed"
            >
              {isLoading ? (
                <>
                  <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
                    <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
                    <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
                  </svg>
                  Memproses...
                </>
              ) : (
                'Masuk'
              )}
            </button>
          </div>
        </form>
      </div>

      {/* Footer */}
      <footer className="mt-8 text-center text-sm text-gray-500 px-4">
        <p>&copy; {new Date().getFullYear()} PT. Trans Retail Indonesia. All Rights Reserved.</p>
      </footer>
    </div>
  );
}

export default LoginPage;