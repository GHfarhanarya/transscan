import React, { useState, useMemo, useEffect, useRef } from 'react';
import ScanLogo from '../assets/logo-app.svg?react';
import RealtimeDateTime from './RealtimeDateTime';
import CalendarCard from '../components/CalendarCard';

// --- Icon Components ---
const MenuIcon = (props) => (
  <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <line x1="4" x2="20" y1="12" y2="12" /><line x1="4" x2="20" y1="6" y2="6" /><line x1="4" x2="20" y1="18" y2="18" />
  </svg>
);
const UsersIcon = (props) => (
  <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
    <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><path d="M22 21v-2a4 4 0 0 0-3-3.87" /><path d="M16 3.13a4 4 0 0 1 0 7.75" />
  </svg>
);
const HomeIcon = (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" /><polyline points="9 22 9 12 15 12 15 22" />
    </svg>
);
const UserPlusIcon = (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" /><line x1="19" x2="19" y1="8" y2="14" /><line x1="22" x2="16" y1="11" y2="11" />
    </svg>
);
const SearchIcon = (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <circle cx="11" cy="11" r="8" /><line x1="21" x2="16.65" y1="21" y2="16.65" />
    </svg>
);
const EditIcon = (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7" /><path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z" />
    </svg>
);
const DeleteIcon = (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <polyline points="3 6 5 6 21 6" /><path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2" /><line x1="10" y1="11" x2="10" y2="17" /><line x1="14" y1="11" x2="14" y2="17" />
    </svg>
);
const CloseIcon = (props) => (
    <svg {...props} xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
        <line x1="18" y1="6" x2="6" y2="18" /><line x1="6" y1="6" x2="18" y2="18" />
    </svg>
);
const SpinnerIcon = (props) => (
    <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
        <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
    </svg>
);

// --- Konfigurasi API ---
const API_URL = 'http://35.219.66.90'; 
const PAGE_SIZE_OPTIONS = [5, 25, 50];

// --- Komponen Modal Pengguna
const UserModal = ({ isOpen, onClose, onSave, user, mode }) => {
    const [formData, setFormData] = useState({});
    const [isSaving, setIsSaving] = useState(false);
    const [error, setError] = useState('');
    const [showPassword, setShowPassword] = useState(false);
    const [resetNotif, setResetNotif] = useState(false);

    useEffect(() => {
        // inisialisasi form
        const initialData = {
            employee_id: user?.employee_id || '',
            name: user?.name || '',
            job_title: user?.job_title || '',
            role: user?.role || 'staff',
            password: '123456',
            status: typeof user?.status === 'boolean' ? user.status : true,
        };
        setFormData(initialData);
        setError(''); // Reset error setiap kali modal dibuka
    }, [user, mode]);

    if (!isOpen) return null;

    const handleChange = (e) => {
        const { name, value } = e.target;
        setFormData(prev => ({ ...prev, [name]: value }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        setIsSaving(true);
        setError('');
        try {
            // Panggil fungsi onSave yang merupakan fungsi async dari parent
            await onSave(formData);
        } catch (err) {
            setError(err.message || 'Terjadi kesalahan yang tidak diketahui.');
        } finally {
            setIsSaving(false);
        }
    };

    const isDeleteMode = mode === 'delete';
    const title = { add: 'Add New User', edit: 'Edit User Data', delete: 'Delete User' }[mode];

    return (
        <div className="fixed inset-0 bg-black bg-opacity-60 z-50 flex justify-center items-center p-4 transition-opacity duration-300">
            <div className="bg-white rounded-lg shadow-xl w-full max-w-md transform transition-all duration-300 scale-95 opacity-0 animate-fade-in-scale">
                <style>{`.animate-fade-in-scale { animation: fadeInScale 0.3s ease-out forwards; } @keyframes fadeInScale { from { transform: scale(0.95); opacity: 0; } to { transform: scale(1); opacity: 1; } }`}</style>
                <div className="flex justify-between items-center p-5 border-b bg-gray-50 rounded-t-lg">
                    <h3 className="text-lg font-semibold text-gray-800">{title}</h3>
                    <button onClick={onClose} className="text-gray-400 hover:text-gray-600"><CloseIcon className="w-6 h-6" /></button>
                </div>
                {isDeleteMode ? (
                    <div className="p-6">
                        <p className="text-gray-700">Apakah Anda yakin ingin menghapus pengguna <strong>{user?.name}</strong>? Tindakan ini tidak dapat dibatalkan.</p>
                        <div className="flex justify-end gap-4 mt-6">
                            <button onClick={onClose} className="px-4 py-2 rounded-md text-sm font-medium text-gray-700 bg-gray-100 hover:bg-gray-200">Cancel</button>
                            <button onClick={() => onSave(user.employee_id)} className="px-4 py-2 rounded-md text-sm font-medium text-white bg-red-600 hover:bg-red-700">Delete</button>
                        </div>
                    </div>
                ) : (
                    <form onSubmit={handleSubmit}>
                        <div className="p-6 space-y-4">
                            {error && <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded relative" role="alert">{error}</div>}
                            <div>
                                <label htmlFor="employee_id" className="block text-sm font-medium text-gray-700">Employee ID</label>
                                <input type="text" name="employee_id" value={formData.employee_id} onChange={handleChange} required disabled={mode === 'edit'} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 sm:text-sm disabled:bg-gray-100" />
                            </div>
                            <div>
                                <label htmlFor="name" className="block text-sm font-medium text-gray-700">Full Name</label>
                                <input type="text" name="name" value={formData.name} onChange={handleChange} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 sm:text-sm" />
                            </div>
                             <div>
                                <label htmlFor="job_title" className="block text-sm font-medium text-gray-700">Job Title</label>
                                <input type="text" name="job_title" value={formData.job_title} onChange={handleChange} required className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 sm:text-sm" />
                            </div>
                            <div>
                                <label htmlFor="role" className="block text-sm font-medium text-gray-700">Role</label>
                                <select name="role" value={formData.role} onChange={handleChange} className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 sm:text-sm">
                                    <option value="admin">Admin</option>
                                    <option value="management">Management</option>
                                    <option value="staff">Staff</option>
                                </select>
                            </div>
                            <div>
                                <label htmlFor="password" className="block text-sm font-medium text-gray-700">Password</label>
                                {mode === 'add' ? (
                                    <div className="relative">
                                        <input
                                            type={showPassword ? "text" : "password"}
                                            name="password"
                                            value={formData.password}
                                            onChange={handleChange}
                                            required
                                            className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 sm:text-sm pr-10"
                                        />
                                        <button
                                            type="button"
                                            tabIndex={-1}
                                            onClick={() => setShowPassword(v => !v)}
                                            className="absolute inset-y-0 right-0 px-3 flex items-center text-gray-500 focus:outline-none"
                                        >
                                            {showPassword ? (
                                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 12a3 3 0 11-6 0 3 3 0 016 0z" /><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-.19.655-.438 1.283-.74 1.874M15.362 17.362A9.953 9.953 0 0112 19c-4.478 0-8.268-2.943-9.542-7a9.956 9.956 0 012.293-3.95M9.88 9.88A3 3 0 0115 12m0 0a3 3 0 01-5.12-2.12" /></svg>
                                            ) : (
                                                <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13.875 18.825A10.05 10.05 0 0112 19c-4.478 0-8.268-2.943-9.542-7a9.956 9.956 0 012.293-3.95m1.414-1.414A9.953 9.953 0 0112 5c4.478 0 8.268 2.943 9.542 7a9.956 9.956 0 01-4.043 5.132M15 12a3 3 0 11-6 0 3 3 0 016 0zm-6.364 6.364L6 18m0 0l-2-2m2 2l2-2m-2 2l2-2" /></svg>
                                            )}
                                        </button>
                                    </div>
                                ) : mode === 'edit' ? (
                                    <div className="flex items-center gap-2 mt-1">
                                        <button
                                            type="button"
                                            className="px-3 py-1 rounded bg-gray-200 text-gray-700 hover:bg-gray-300 border border-gray-300 text-sm"
                                            onClick={() => {
                                                setFormData(prev => ({ ...prev, password: '123456' }));
                                                setResetNotif(true);
                                                setTimeout(() => setResetNotif(false), 2000);
                                            }}
                                        >Reset Password</button>
                                        {resetNotif && (
                                            <span className="text-green-600 text-xs">Password berhasil direset!</span>
                                        )}
                                    </div>
                                ) : null}
                                {mode === 'add' && <p className="mt-1 text-xs text-gray-500">Default Password 123456</p>}
                            </div>
                            {/* Status aktif/non-aktif hanya pada edit */}
                            {mode === 'edit' && (
                                <div>
                                    <label htmlFor="status" className="block text-sm font-medium text-gray-700">Status Akun</label>
                                    <select
                                        name="status"
                                        value={formData.status ? 'active' : 'inactive'}
                                        onChange={e => setFormData(prev => ({ ...prev, status: e.target.value === 'active' }))}
                                        className="mt-1 block w-full rounded-md border-gray-300 shadow-sm focus:border-red-500 focus:ring-red-500 sm:text-sm"
                                    >
                                        <option value="active">Aktif</option>
                                        <option value="inactive">Tidak Aktif</option>
                                    </select>
                                </div>
                            )}
                        </div>
                        <div className="bg-gray-50 px-6 py-4 flex justify-end gap-4 rounded-b-lg">
                            <button type="button" onClick={onClose} className="px-4 py-2 rounded-md text-sm font-medium text-gray-700 bg-white border border-gray-300 hover:bg-gray-50">Cancel</button>
                            <button type="submit" disabled={isSaving} className="inline-flex items-center px-4 py-2 rounded-md text-sm font-medium text-white bg-red-600 hover:bg-red-700 disabled:bg-red-400">
                                {isSaving && <SpinnerIcon />}
                                {isSaving ? 'Saving...' : 'Save Changes'}
                            </button>
                        </div>
                    </form>
                )}
            </div>
        </div>
    );
};


// --- Main Dashboard Component ---
export default function DashboardPage() {
    const [usersData, setUsersData] = useState([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState(null);
    const [isMenuOpen, setIsMenuOpen] = useState(false);
    const [isProfileOpen, setIsProfileOpen] = useState(false);
    const [searchTerm, setSearchTerm] = useState('');
    const [filterRole, setFilterRole] = useState('All');
    const [currentPage, setCurrentPage] = useState(1);
    const [itemsPerPage, setItemsPerPage] = useState(PAGE_SIZE_OPTIONS[0]);
    const profileRef = useRef(null);
    // Ambil nama admin login dari localStorage
    const [userName, setUserName] = useState(() => {
        let name = 'Admin';
        try {
            const userData = localStorage.getItem('userData');
            if (userData) {
                const parsed = JSON.parse(userData);
                name = parsed.name || parsed.username || 'Admin';
            } else {
                name = localStorage.getItem('userName') || 'Admin';
            }
        } catch {
            name = 'Admin';
        }
        return name;
    });

    // Modal State
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [modalMode, setModalMode] = useState('add');
    const [currentUser, setCurrentUser] = useState(null);

    // --- Pengambilan Data dari API ---
    const fetchUsers = async () => {
        setIsLoading(true);
        setError(null);
        try {
            const token = localStorage.getItem('jwtToken');
            if (!token) {
                // Jika tidak ada token, langsung logout/redirect
                handleLogout();
                return;
            }

            const response = await fetch(`${API_URL}/users`, {
                headers: {
                    // Sertakan token di Authorization header dengan format yang benar
                    'Authorization': token
                }
            });

            if (response.status === 401) {
                // Jika token tidak valid/expired, logout
                handleLogout();
                return;
            }

            if (!response.ok) {
                throw new Error('Gagal mengambil data pengguna.');
            }

            const data = await response.json();
            const dataWithAvatars = data.map(user => ({
                ...user,
                avatar: `https://placehold.co/40x40/E2E8F0/4A5568?text=${user.name.charAt(0)}`
            }));
            setUsersData(dataWithAvatars);
        } catch (error) {
            setError(error.message);
        } finally {
            setIsLoading(false);
        }
    };

    // Ambil data awal saat komponen dimuat
    useEffect(() => {
        fetchUsers();
    }, []);

    // Tutup dropdown profil saat klik di luar
    useEffect(() => {
        const handleClickOutside = (event) => {
            if (profileRef.current && !profileRef.current.contains(event.target)) {
                setIsProfileOpen(false);
            }
        };
        document.addEventListener("mousedown", handleClickOutside);
        return () => document.removeEventListener("mousedown", handleClickOutside);
    }, []);

    const filteredUsers = useMemo(() => {
        setCurrentPage(1);
        return usersData
            .filter(user => {
                const term = searchTerm.toLowerCase();
                const idMatch = user.employee_id && user.employee_id.toLowerCase().includes(term);
                const nameMatch = user.name && user.name.toLowerCase().includes(term);
                return idMatch || nameMatch;
            })
            .filter(user => filterRole === 'All' || user.role === filterRole);
    }, [searchTerm, filterRole, usersData]);

    const totalPages = Math.ceil(filteredUsers.length / itemsPerPage);
    const startIndex = (currentPage - 1) * itemsPerPage;
    const endIndex = startIndex + itemsPerPage;
    const paginatedUsers = filteredUsers.slice(startIndex, endIndex);

    const goToNextPage = () => setCurrentPage((page) => Math.min(page + 1, totalPages));
    const goToPreviousPage = () => setCurrentPage((page) => Math.max(page - 1, 1));
    const handlePageSizeChange = (e) => {
        setItemsPerPage(Number(e.target.value));
        setCurrentPage(1);
    };

    // --- Handler untuk CRUD ---
    const handleOpenModal = (mode, user = null) => {
        setModalMode(mode);
        setCurrentUser(user);
        setIsModalOpen(true);
    };

    const handleCloseModal = () => {
        setIsModalOpen(false);
        setCurrentUser(null);
    };

    const handleSaveUser = async (formData) => {
        let url = `${API_URL}/users`;
        let method = 'POST';

        if (modalMode === 'edit') {
            url = `${API_URL}/users/${formData.employee_id}`;
            method = 'PUT';
        }

        const token = localStorage.getItem('jwtToken');
        if (!token) {
            handleLogout();
            return;
        }

        const response = await fetch(url, {
            method,
            headers: { 
                'Content-Type': 'application/json',
                'Authorization': token
            },
            body: JSON.stringify(formData),
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.message || `Gagal untuk ${modalMode} pengguna.`);
        }
        
        handleCloseModal();
        fetchUsers(); // Muat ulang data setelah berhasil menyimpan
    };

    const handleDeleteUser = async (employeeId) => {
        const token = localStorage.getItem('jwtToken');
        if (!token) {
            handleLogout();
            return;
        }

        const response = await fetch(`${API_URL}/users/${employeeId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': token
            }
        });

        if (!response.ok) {
            const errorData = await response.json();
            throw new Error(errorData.message || 'Gagal menghapus pengguna.');
        }

        handleCloseModal();
        fetchUsers();
    };

    const handleLogout = () => {
        localStorage.removeItem('jwtToken');
        console.log("Logging out...");
        setIsProfileOpen(false);
        window.location.href = '/login'; 
    };
    
    return (
        <div className="min-h-screen w-screen bg-gray-50 font-sans text-gray-800">
            <UserModal 
                isOpen={isModalOpen}
                onClose={handleCloseModal}
                onSave={modalMode === 'delete' ? handleDeleteUser : handleSaveUser}
                user={currentUser}
                mode={modalMode}
            />
            {/* Top Navigation */}
            <nav className="bg-white shadow-sm sticky top-0 z-40">
                <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
                    <div className="flex items-center justify-between h-16">
                        <div className="flex items-center">
                            <div className="flex-shrink-0">
                                 <ScanLogo className="h-8 sm:h-8 w-auto text-red-600"/>
                            </div>
                            <div className="hidden md:block">
                                <div className="ml-10 flex items-baseline space-x-4">
                                    <a href="#" className="bg-red-50 text-red-700 px-3 py-2 rounded-md text-sm font-medium flex items-center">
                                        <HomeIcon className="w-5 h-5 mr-2"/>Dashboard
                                    </a>
                                </div>
                            </div>
                        </div>
                        <div className="hidden md:block">
                            <div className="ml-4 flex items-center md:ml-6">
                                <div className="ml-3 relative flex items-center gap-2" ref={profileRef}>
                                    <span className="text-gray-800 font-medium text-sm truncate max-w-[120px]">{userName}</span>
                                    <button onClick={() => setIsProfileOpen(!isProfileOpen)} className="max-w-xs bg-gray-800 rounded-full flex items-center text-sm focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-white">
                                        <span className="sr-only">Open user menu</span>
                                        <img className="h-8 w-8 rounded-full" src="https://placehold.co/32x32/7C3AED/FFFFFF?text=A" alt="Admin Avatar" />
                                    </button>
                                    {isProfileOpen && (
                                        <div className="origin-top absolute left-1/2 top-full mt-2 -translate-x-1/2 w-48 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 z-50">
                                            <a href="#" className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">Your Profile</a>
                                            <a href="#" onClick={handleLogout} className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-100">Sign out</a>
                                        </div>
                                    )}
                                </div>
                            </div>
                        </div>
                        <div className="-mr-2 flex md:hidden">
                            <button onClick={() => setIsMenuOpen(!isMenuOpen)} className="bg-gray-100 inline-flex items-center justify-center p-2 rounded-md text-gray-600 hover:text-gray-900 hover:bg-gray-200 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500">
                                <span className="sr-only">Open main menu</span>
                                <MenuIcon className="h-6 w-6" />
                            </button>
                        </div>
                    </div>
                </div>
                {isMenuOpen && (
                    <div className="md:hidden">
                        <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3">
                             <a href="#" className="bg-red-50 text-red-700 block px-3 py-2 rounded-md text-base font-medium flex items-center"><HomeIcon className="w-5 h-5 mr-3"/>Dashboard</a>
                        </div>
                        <div className="pt-4 pb-3 border-t border-gray-200">
                            <div className="flex items-center px-5">
                                <div className="flex-shrink-0"><img className="h-10 w-10 rounded-full" src="https://placehold.co/40x40/7C3AED/FFFFFF?text=A" alt="" /></div>
                                <div className="ml-3">
                                    <div className="text-base font-medium leading-none text-gray-800">Admin User</div>
                                    <div className="text-sm font-medium leading-none text-gray-500">admin@example.com</div>
                                </div>
                            </div>
                            <div className="mt-3 px-2 space-y-1">
                                <a href="#" className="block rounded-md px-3 py-2 text-base font-medium text-gray-500 hover:bg-gray-100 hover:text-gray-800">Your Profile</a>
                                <a href="#" onClick={handleLogout} className="block rounded-md px-3 py-2 text-base font-medium text-gray-500 hover:bg-gray-100 hover:text-gray-800">Sign out</a>
                            </div>
                        </div>
                    </div>
                )}
            </nav>

            {/* Main Content */}
            <main>
                <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
                                        <header className="px-4 sm:px-0 mb-8 flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
                                                <div>
                                                    <h1 className="text-3xl font-bold leading-tight text-gray-900">Dashboard</h1>
                                                    <RealtimeDateTime />
                                                </div>
                                                <div className="flex-shrink-0">
                                                    <CalendarCard />
                                                </div>
                                        </header>

                    {/* User Management Section */}
                    <div className="mt-10 px-4 sm:px-0">
                         <div className="sm:flex sm:items-center sm:justify-between">
                            <div>
                                <h2 className="text-2xl font-bold text-gray-900">User Management</h2>
                                <p className="mt-1 text-sm text-gray-600">Add, edit, or delete user accounts.</p>
                            </div>
                            <div className="mt-4 sm:mt-0">
                                <button onClick={() => handleOpenModal('add')} type="button" className="inline-flex items-center justify-center rounded-md border border-transparent bg-red-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2">
                                    <UserPlusIcon className="-ml-1 mr-2 h-5 w-5" />Add user
                                </button>
                            </div>
                        </div>

                        {/* Table Controls */}
                        <div className="mt-6 grid grid-cols-1 gap-y-4 sm:grid-cols-2 sm:gap-x-4">
                            <div className="relative">
                                <div className="pointer-events-none absolute inset-y-0 left-0 flex items-center pl-3"><SearchIcon className="h-5 w-5 text-gray-400" /></div>
                                <input type="text" placeholder="Search by name or ID..." value={searchTerm} onChange={(e) => setSearchTerm(e.target.value)} className="block w-full rounded-md border-gray-300 bg-white py-2 pl-10 pr-3 text-sm placeholder-gray-500 shadow-sm focus:border-red-500 focus:ring-red-500"/>
                            </div>
                            <div className="flex flex-col sm:flex-row gap-2">
                                <select id="role" name="role" value={filterRole} onChange={(e) => setFilterRole(e.target.value)} className="block w-full rounded-md border-gray-300 py-2 pl-3 pr-10 text-base shadow-sm focus:border-red-500 focus:outline-none focus:ring-red-500 sm:text-sm">
                                    <option value="All">All Roles</option>
                                    <option value="admin">Admin</option>
                                    <option value="management">Management</option>
                                    <option value="staff">Staff</option>
                                </select>
                            </div>
                        </div>

                        {/* Simple Pagination Atas */}
                        <div className="flex items-center justify-end mt-4 mb-2">
                            <div className="flex items-center gap-4">
                                {/* Page size selector */}
                                <div className="flex items-center gap-1">
                                    <span className="text-sm text-gray-600">Page size:</span>
                                    <select value={itemsPerPage} onChange={handlePageSizeChange} className="rounded border-gray-300 py-1 pl-2 pr-6 text-sm focus:border-red-500 focus:ring-red-500">
                                        {PAGE_SIZE_OPTIONS.map(opt => (
                                            <option key={opt} value={opt}>{opt}</option>
                                        ))}
                                    </select>
                                </div>
                                {/* Pagination */}
                                <div className="flex items-center gap-2">
                                    <button onClick={goToPreviousPage} disabled={currentPage === 1} className="px-2 py-1 rounded bg-gray-200 text-gray-600 disabled:opacity-50">&lt;</button>
                                    <span className="text-sm">Page {totalPages === 0 ? 0 : currentPage} of {totalPages}</span>
                                    <button onClick={goToNextPage} disabled={currentPage === totalPages || filteredUsers.length === 0} className="px-2 py-1 rounded bg-gray-200 text-gray-600 disabled:opacity-50">&gt;</button>
                                </div>
                            </div>
                        </div>

                        {/* User Table */}
                        <div className="mt-4 flex flex-col">
                            <div className="-my-2 -mx-4 overflow-x-auto sm:-mx-6 lg:-mx-8">
                                <div className="inline-block min-w-full py-2 align-middle md:px-6 lg:px-8">
                                    <div className="overflow-hidden shadow ring-1 ring-black ring-opacity-5 md:rounded-lg">
                                        {error && <div className="bg-red-100 border-l-4 border-red-500 text-red-700 p-4 m-4" role="alert"><p>{error}</p></div>}
                                        <table className="min-w-full divide-y divide-gray-300">
                                            <thead className="bg-gray-50">
                                                <tr>
                                                    <th scope="col" className="py-3.5 pl-4 pr-3 text-left text-sm font-semibold text-gray-900 sm:pl-6">Name</th>
                                                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 hidden sm:table-cell">Employee ID</th>
                                                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Role</th>
                                                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Status</th>
                                                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900 hidden md:table-cell">Job Title</th>
                                                    <th scope="col" className="px-3 py-3.5 text-left text-sm font-semibold text-gray-900">Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody className="divide-y divide-gray-200 bg-white">
                                                {isLoading ? (
                                                    <tr><td colSpan="5" className="text-center py-10 text-gray-500">Loading user data...</td></tr>
                                                ) : paginatedUsers.length > 0 ? (
                                                    paginatedUsers.map((user) => (
                                                        <tr key={user.employee_id}>
                                                            <td className="whitespace-nowrap py-4 pl-4 pr-3 text-sm sm:pl-6">
                                                                <div className="flex items-center">
                                                                    <div className="h-10 w-10 flex-shrink-0">
                                                                        <img className="h-10 w-10 rounded-full" src={user.avatar} onError={(e) => { e.target.onerror = null; e.target.src = 'https://placehold.co/40x40/E2E8F0/4A5568?text=?'; }} alt={`${user.name} avatar`} />
                                                                    </div>
                                                                    <div className="ml-4">
                                                                        <div className="font-medium text-gray-900">{user.name}</div>
                                                                    </div>
                                                                </div>
                                                            </td>
                                                            <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500 hidden sm:table-cell">{user.employee_id}</td>
                                                            <td className="whitespace-nowrap px-3 py-4 text-sm">
                                                                {user.role === 'admin' && (
                                                                    <span className="inline-block px-2 py-1 text-xs font-semibold rounded bg-red-100 text-red-700 border border-red-400">Admin</span>
                                                                )}
                                                                {user.role === 'management' && (
                                                                    <span className="inline-block px-2 py-1 text-xs font-semibold rounded bg-yellow-100 text-yellow-700 border border-yellow-400">Management</span>
                                                                )}
                                                                {user.role === 'staff' && (
                                                                    <span className="inline-block px-2 py-1 text-xs font-semibold rounded bg-green-100 text-green-700 border border-green-400">Staff</span>
                                                                )}
                                                            </td>
                                                            <td className="whitespace-nowrap px-3 py-4 text-sm">
                                                                {user.status ? (
                                                                    <span className="inline-block px-2 py-1 text-xs font-semibold rounded bg-green-100 text-green-700 border border-green-400">Aktif</span>
                                                                ) : (
                                                                    <span className="inline-block px-2 py-1 text-xs font-semibold rounded bg-red-100 text-red-700 border border-red-400">Tidak Aktif</span>
                                                                )}
                                                            </td>
                                                            <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-500 hidden md:table-cell">{user.job_title || '-'}</td>
                                                            <td className="relative whitespace-nowrap py-4 pl-3 pr-4 text-left text-sm font-medium sm:pr-6">
                                                                <div className="flex items-center gap-x-4">
                                                                    <button onClick={() => handleOpenModal('edit', user)} className="text-red-600 hover:text-red-900"><EditIcon className="w-5 h-5" /></button>
                                                                    <button onClick={() => handleOpenModal('delete', user)} className="text-red-600 hover:text-red-900"><DeleteIcon className="w-5 h-5" /></button>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    ))
                                                ) : (
                                                    <tr><td colSpan="5" className="text-center py-10 text-gray-500">No users found.</td></tr>
                                                )}
                                            </tbody>
                                        </table>
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        {/* Pagination Controls bawah*/}
                        <div className="flex flex-col sm:flex-row items-center justify-between border-t border-gray-200 bg-white px-4 py-3 sm:px-6 mt-4 rounded-b-lg shadow ring-1 ring-black ring-opacity-5 gap-2">
                            <div className="w-full sm:w-auto text-center sm:text-left mb-2 sm:mb-0">
                                <p className="text-sm text-gray-700">Showing <span className="font-medium">{isLoading || filteredUsers.length === 0 ? 0 : startIndex + 1}</span> to <span className="font-medium">{Math.min(endIndex, filteredUsers.length)}</span> of <span className="font-medium">{filteredUsers.length}</span> results</p>
                            </div>
                            <div className="flex items-center gap-2">
                                <button onClick={goToPreviousPage} disabled={currentPage === 1} className="px-2 py-1 rounded bg-gray-200 text-gray-600 disabled:opacity-50">&lt;</button>
                                <span className="text-sm">Page {totalPages === 0 ? 0 : currentPage} of {totalPages}</span>
                                <button onClick={goToNextPage} disabled={currentPage === totalPages || filteredUsers.length === 0} className="px-2 py-1 rounded bg-gray-200 text-gray-600 disabled:opacity-50">&gt;</button>
                            </div>
                        </div>
                    </div>
                </div>
            </main>
        </div>
    );
}
