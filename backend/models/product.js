const { DataTypes } = require('sequelize');
const sequelize = require('../db');

const Product = sequelize.define('Product', {
  id: {
    type: DataTypes.INTEGER,
    primaryKey: true,
    autoIncrement: true
  },
  barcode: {
    type: DataTypes.STRING(50),
    allowNull: false,
    unique: true
  },
  item_name: {
    type: DataTypes.STRING(255),
    allowNull: false
  },
  item_code: {
    type: DataTypes.STRING(50),
    allowNull: false
  },
  normal_price: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: false
  },
  harga_promo: {
    type: DataTypes.DECIMAL(10, 2),
    allowNull: true
  },
  stock: {
    type: DataTypes.INTEGER,
    allowNull: false
  },

  image: {
    type: DataTypes.STRING(500),
    allowNull: true
  },
  
}, {
  tableName: 'products',
  timestamps: false
});

module.exports = Product;
