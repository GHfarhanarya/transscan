const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const products = require('./data/products');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

app.get('/product/:barcode', (req, res) => {
  const barcode = req.params.barcode;
  const product = products.find(p => p.barcode === barcode);
  if (!product) return res.status(404).json({ message: "Produk tidak ditemukan" });

  const promoCount = {};
  product.pricePromo.forEach(p => promoCount[p] = (promoCount[p] || 0) + 1);
  const dominantPromo = Object.keys(promoCount).reduce((a, b) =>
    promoCount[a] >= promoCount[b] ? a : b
  );

  res.json({
    name: product.name,
    barcode: product.barcode,
    priceNormal: product.priceNormal,
    pricePromo: parseInt(dominantPromo),
    stock: product.stock
  });
});

app.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));
