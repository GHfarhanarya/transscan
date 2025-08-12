
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

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
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static('uploads')); // Serve uploaded files

// Buat direktori uploads jika belum ada
const fs = require('fs');
if (!fs.existsSync('uploads')){
    fs.mkdirSync('uploads');
}

// ===== AUTH ROUTES =====
// Login endpoint
app.post('/login', async (req, res) => {
  try {
    const { employee_id, password } = req.body;

    if (!employee_id || !password) {
      return res.status(400).json({ message: 'Employee ID dan password wajib diisi' });
    }

    // Cari user berdasarkan employee_id
    const user = await User.findByPk(employee_id);
    if (!user) {
      return res.status(401).json({ message: 'Employee ID atau password salah' });
    }

    // Verifikasi password
    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return res.status(401).json({ message: 'Employee ID atau password salah' });
    }

    // Generate JWT token
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
        role: user.role
      }
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
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

// Tambah produk baru (hanya admin)
app.post('/products', authenticateToken, authorizeRole(['admin']), async (req, res) => {
  try {
    const { name, barcode, price_normal, price_promo, stock, promo_end } = req.body;
    const product = await Product.create({ 
      name, 
      barcode, 
      price_normal, 
      price_promo: price_promo || null, 
      stock,
      promo_end: promo_end || null
    });
    res.status(201).json(product);
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
      name: product.name,
      barcode: product.barcode,
      priceNormal: product.price_normal,
      pricePromo: product.price_promo,
      stock: product.stock,
      image: product.image ? `http://10.0.2.2:3000/uploads/${product.image}` : null
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
      name: product.name,
      barcode: product.barcode,
      priceNormal: product.price_normal,
      pricePromo: product.price_promo,
      stock: product.stock,
      image: product.image ? `http://10.0.2.2:3000/uploads/${product.image}` : null
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Search berdasarkan nama produk
app.get('/product/search/name/:name', async (req, res) => {
  try {
    const searchName = req.params.name;
    const product = await Product.findOne({ 
      where: { 
        name: {
          [require('sequelize').Op.like]: `%${searchName}%`
        }
      } 
    });
    if (!product) return res.status(404).json({ message: "Produk tidak ditemukan" });
    res.json({
      name: product.name,
      barcode: product.barcode,
      priceNormal: product.price_normal,
      pricePromo: product.price_promo,
      stock: product.stock,
      image: product.image ? `http://10.0.2.2:3000/uploads/${product.image}` : null
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Update gambar produk (hanya admin)
app.post('/product/update-image/:barcode', authenticateToken, authorizeRole(['admin']), upload.single('image'), async (req, res) => {
  try {
    const barcode = req.params.barcode;
    const product = await Product.findOne({ where: { barcode } });
    
    if (!product) {
      return res.status(404).json({ message: "Produk tidak ditemukan" });
    }
    
    if (!req.file) {
      return res.status(400).json({ message: "Tidak ada file yang diupload" });
    }

    // Update image field
    await Product.update(
      { image: req.file.filename },
      { where: { barcode } }
    );

    res.json({ 
      message: "Gambar produk berhasil diupdate",
      imageUrl: `http://10.0.2.2:3000/uploads/${req.file.filename}`
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

sequelize.sync().then(() => {
  app.listen(PORT, '0.0.0.0', () => console.log(`Server running on http://0.0.0.0:${PORT}`));
});
