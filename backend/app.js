
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const multer = require('multer');
const path = require('path');

const sequelize = require('./db');
const Product = require('./models/product');

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

// Ambil semua produk
app.get('/products', async (req, res) => {
  try {
    const products = await Product.findAll();
    res.json(products);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Tambah produk baru
app.post('/products', async (req, res) => {
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

app.get('/product/:barcode', async (req, res) => {
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
      image: product.image ? `http://192.168.137.1:3000/uploads/${product.image}` : null
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Update gambar produk
app.post('/product/update-image/:barcode', upload.single('image'), async (req, res) => {
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
      imageUrl: `http://192.168.137.1:3000/uploads/${req.file.filename}`
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

sequelize.sync().then(() => {
  app.listen(PORT, '0.0.0.0', () => console.log(`Server running on http://0.0.0.0:${PORT}`));
});
