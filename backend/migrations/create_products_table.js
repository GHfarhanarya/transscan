module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.createTable('products', {
      id: {
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
        type: Sequelize.INTEGER
      },
      barcode: {
        type: Sequelize.STRING(50),
        allowNull: false,
        unique: true
      },
      item_name: {
        type: Sequelize.STRING(255),
        allowNull: false
      },
      item_code: {
        type: Sequelize.STRING(50),
        allowNull: true
      },
      normal_price: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: false
      },
      harga_promo: {
        type: Sequelize.DECIMAL(10, 2),
        allowNull: true
      },
      stock: {
        type: Sequelize.INTEGER,
        allowNull: false
      },
      image: {
        type: Sequelize.STRING(500),
        allowNull: true
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('products');
  }
};
