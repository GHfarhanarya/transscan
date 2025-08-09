
const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const sequelize = require('./db');
const Product = require('./models/product');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

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
      stock: product.stock
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

sequelize.sync().then(() => {
  app.listen(PORT, '0.0.0.0', () => console.log(`Server running on http://0.0.0.0:${PORT}`));
});
