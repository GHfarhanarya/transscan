const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const http = require('http');
const { Server } = require('socket.io');

// Pastikan dotenv dimuat paling atas untuk membaca file .env
require('dotenv').config();

const sequelize = require('./db');
const Product = require('./models/product');
const User = require('./models/user');
const { authenticateToken, authorizeRole, JWT_SECRET } = require('./middleware/auth');

// Konfigurasi multer untuk upload gambar
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/');
  },
  filename: function (req, file, cb) {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ 
  storage: storage,
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Bukan gambar! Mohon upload file gambar.'), false);
    }
  }
});

const app = express();
const server = http.createServer(app);
const io = new Server(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"]
  }
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  console.log('User connected:', socket.id);
  
  socket.on('disconnect', () => {
    console.log('User disconnected:', socket.id);
  });
});

// Export io untuk digunakan di utils lain
global.io = io;

// Gunakan PORT dari .env atau default ke 3000
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static('uploads')); // Serve uploaded files

// Buat direktori uploads jika belum ada
if (!fs.existsSync('uploads')){
    fs.mkdirSync('uploads');
}

// ===== ROUTES =====
const logActivity = require('./utils/logActivity');
const activityLogRoutes = require('./routes/activityLog');
app.use('/activity-logs', activityLogRoutes);
// Login endpoint
app.post('/login', async (req, res) => {
  try {
    const { employee_id, password } = req.body;

    if (!employee_id || !password) {
      return res.status(400).json({ message: 'Employee ID dan password wajib diisi' });
    }

    const user = await User.findByPk(employee_id);
    if (!user) {
      return res.status(401).json({ message: 'Employee ID atau password salah' });
    }
    if (user.status === false) {
      return res.status(403).json({ message: 'Akun Anda sudah non-aktif. Silakan hubungi admin.' });
    }
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Employee ID atau password salah' });
    }

    const token = jwt.sign(
      { 
        employee_id: user.employee_id,
        name: user.name,
        role: user.role 
      },
      JWT_SECRET,
      { expiresIn: '24h' }
    );

    res.json({
      message: 'Login berhasil',
      token,
      user: {
        employee_id: user.employee_id,
        name: user.name,
        role: user.role,
	job_title:user.job_title
      }
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

//login endpoint admin
app.post('/admin/login', async (req, res) => {
  try{
    const { employee_id, password } = req.body;

    if (!employee_id || !password){
      return res.status(400).json({
        message: 'Employee ID dan password wajib diisi'
      });
    }

    const user = await User.findOne({ where: { employee_id: employee_id } });
    if (!user){
      return res.status(401).json({
        message: 'Employee ID atau password salah!'
      });
    }
    if (user.status === false || user.status === 0) {
      return res.status(403).json({
        message: 'Akun Anda sudah non-aktif. Silakan hubungi admin.'
      });
    }
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid){
      return res.status(401).json({
        message: 'Employee ID atau password salah!'
      });
    }
    if (user.role !== 'admin'){
      return res.status(403).json({
        message: 'Akses ditolak, Akun anda bukan admin'
      });
    }

    const token = jwt.sign(
      {
        id: user.id,
        employee_id: user.employee_id,
        name: user.name,
        role: user.role
      },
      JWT_SECRET,
      { expiresIn: '8h'}
    );

    res.json({
      message: 'Login Berhasil',
      token: 'Bearer ' + token,
      user: {
        id: user.id,
        employee_id: user.employee_id,
        name: user.name,
        role: user.role
      }
    });
  }catch (err){
    console.error("Error pada login admin:", err);
    res.status(500).json({
      message: 'Server Error', error: err.message
    });
  }
});


// Verify token endpoint
app.get('/verify-token', authenticateToken, (req, res) => {
  res.json({
    message: 'Token valid',
    user: {
      employee_id: req.user.employee_id,
      name: req.user.name,
      role: req.user.role
    }
  });
});

// Ganti password
app.post('/change-password', authenticateToken, async (req, res) => {
  try {
    const { oldPassword, newPassword } = req.body;
    
    if (!oldPassword || !newPassword) {
      return res.status(400).json({ message: "Password lama dan baru harus diisi" });
    }

    if (newPassword.length < 6) {
      return res.status(400).json({ message: "Password baru harus minimal 6 karakter" });
    }

    const user = await User.findOne({ where: { employee_id: req.user.employee_id } });
    if (!user) {
      return res.status(404).json({ message: "User tidak ditemukan" });
    }

    const valid = await bcrypt.compare(oldPassword, user.password);
    if (!valid) {
      return res.status(400).json({ message: "Password lama salah" });
    }

    if (oldPassword === newPassword) {
      return res.status(400).json({ message: "Password baru tidak boleh sama dengan password lama" });
    }

    const hashed = await bcrypt.hash(newPassword, 10);
    await User.update({ password: hashed }, { where: { employee_id: user.employee_id } });

    res.json({ message: "Password berhasil diubah" });
  } catch (err) {
    console.error('Error changing password:', err);
    res.status(500).json({ message: "Terjadi kesalahan saat mengubah password. Silakan coba lagi." });
  }
});



// ===== USER ROUTES (BARU DITAMBAHKAN) =====
// Endpoint data pribadi user
app.get('/user/profile', authenticateToken, async (req, res) => {
  try {
    // Ambil data user dari database berdasarkan employee_id dari token
    const user = await User.findOne({
      where: { employee_id: req.user.employee_id },
      attributes: ['employee_id', 'name', 'job_title', 'role', 'status']
    });
    if (!user) {
      return res.status(404).json({ message: 'User tidak ditemukan' });
    }
    res.json(user);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});
// Ambil semua user (hanya admin)
app.get('/users', authenticateToken, authorizeRole(['admin']), async (req, res) => {
  try {
    // Ambil semua user, tapi jangan sertakan kolom password demi keamanan
    const users = await User.findAll({ 
      attributes: { exclude: ['password'] } 
    });
    res.json(users);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Tambah user baru (hanya admin)
app.post('/users', authenticateToken, authorizeRole(['admin']), async (req, res) => {
  try {
    const { employee_id, name, job_title, role, password } = req.body;

    // Validasi input
    if (!employee_id || !name || !job_title || !role || !password) {
      return res.status(400).json({ message: 'Semua field wajib diisi' });
    }

    // Cek apakah employee_id sudah ada
    const existingUser = await User.findByPk(employee_id);
    if (existingUser) {
      return res.status(400).json({ message: 'Employee ID sudah digunakan' });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Buat user baru
    const newUser = await User.create({
      employee_id,
      name,
      job_title,
      role,
      password: hashedPassword
    });

    await logActivity({
      userId: req.user.employee_id,
      action: 'CREATE_USER',
      details: `Menambah user baru: ${name} (${employee_id})`
    });

    // Return user tanpa password dan timestamps
    const { password: _, created_at: __, updated_at: ___, ...userWithoutPassword } = newUser.toJSON();
    res.status(201).json({ 
      message: 'User berhasil ditambahkan', 
      user: userWithoutPassword 
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Edit user (hanya admin)
app.put('/users/:employee_id', authenticateToken, authorizeRole(['admin']), async (req, res) => {
  try {
    const { employee_id } = req.params;
    const { name, job_title, role, password, status } = req.body;

    // Cari user
    const user = await User.findByPk(employee_id);
    if (!user) {
      return res.status(404).json({ message: 'User tidak ditemukan' });
    }

    // Siapkan data untuk update
    const updateData = {};
    if (name) updateData.name = name;
    if (job_title) updateData.job_title = job_title;
    if (role) updateData.role = role;
    if (typeof status === 'boolean' || status === true || status === false) updateData.status = status;
    // Hash password baru jika ada
    if (password && password.trim() !== '') {
      updateData.password = await bcrypt.hash(password, 10);
    }
    // Update user
    await User.update(updateData, { where: { employee_id } });

    await logActivity({
      userId: req.user.employee_id,
      action: 'UPDATE_USER',
      details: `Update user: ${employee_id}${name ? `, nama: ${name}` : ''}`
    });

    // Ambil user yang sudah diupdate (tanpa password)
    const updatedUser = await User.findByPk(employee_id, {
      attributes: { exclude: ['password'] }
    });

    res.json({ 
      message: 'User berhasil diupdate', 
      user: updatedUser 
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Hapus user (hanya admin)
app.delete('/users/:employee_id', authenticateToken, authorizeRole(['admin']), async (req, res) => {
  try {
    const { employee_id } = req.params;

    // Cari user
    const user = await User.findByPk(employee_id);
    if (!user) {
      return res.status(404).json({ message: 'User tidak ditemukan' });
    }

    // Hapus user
    await User.destroy({ where: { employee_id } });

    await logActivity({
      userId: req.user.employee_id,
      action: 'DELETE_USER',
      details: `Menghapus user: ${user.name} (${employee_id})`
    });

    res.json({ message: 'User berhasil dihapus' });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});


// ===== PRODUCT ROUTES =====

// Ambil semua produk
app.get('/products', async (req, res) => {
  try {
    const products = await Product.findAll();
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Debug endpoint untuk testing
app.get('/debug/products', async (req, res) => {
  try {
    const products = await Product.findAll();
    res.json({
      count: products.length,
      products: products.map(p => ({
        id: p.id,
        barcode: p.barcode,
        item_name: p.item_name,
        normal_price: p.normal_price,
        harga_promo: p.harga_promo,
        stock: p.stock
      }))
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});



// Scan barcode dari kamera
app.get('/product/scan/:barcode', async (req, res) => {
  try {
    const barcode = req.params.barcode;
    const product = await Product.findOne({ where: { barcode } });
    if (!product) return res.status(404).json({ message: "Produk tidak ditemukan" });
    res.json({
      item_name: product.item_name,
      item_code: product.item_code,
      barcode: product.barcode,
      normal_price: product.normal_price,
      harga_promo: product.harga_promo,
      stock: product.stock,
      // PERBAIKAN: Gunakan BASE_URL dari .env
      image: product.image ? `${process.env.BASE_URL}/uploads/${product.image}` : null
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Search berdasarkan barcode (manual input)
app.get('/product/search/barcode/:barcode', async (req, res) => {
  try {
    const barcode = req.params.barcode;
    const product = await Product.findOne({ where: { barcode } });
    if (!product) return res.status(404).json({ message: "Produk tidak ditemukan" });
    res.json({
      item_name: product.item_name,
      item_code: product.item_code,
      barcode: product.barcode,
      normal_price: product.normal_price,
      harga_promo: product.harga_promo,
      stock: product.stock,
      // PERBAIKAN: Gunakan BASE_URL dari .env
      image: product.image ? `${process.env.BASE_URL}/uploads/${product.image}` : null
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Search berdasarkan nama produk
app.get('/product/search/name/:name', async (req, res) => {
  try {
    const searchName = req.params.name;
    const products = await Product.findAll({ 
      where: { 
        item_name: {
          [require('sequelize').Op.like]: `%${searchName}%`
        }
      },
      limit: 50 // Batasi hasil pencarian
    });
    
    if (products.length === 0) {
      return res.status(404).json({ message: "Produk tidak ditemukan" });
    }

    // Format response sebagai array of products
    const formattedProducts = products.map(product => ({
      item_name: product.item_name,
      item_code: product.item_code,
      barcode: product.barcode,
      normal_price: product.normal_price,
      harga_promo: product.harga_promo,
      stock: product.stock,
      image: product.image ? `${process.env.BASE_URL}/uploads/${product.image}` : null
    }));

    res.json(formattedProducts);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});


// Sinkronisasi database dan jalankan server
sequelize.sync().then(() => {
  server.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on http://0.0.0.0:${PORT}`);
    console.log('Socket.IO server ready for real-time connections');
  });
});
