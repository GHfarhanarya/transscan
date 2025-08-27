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
        type: Sequelize.STRING,
        allowNull: false
      },
      item_name: {
        type: Sequelize.STRING,
        allowNull: false
      },
      item_code: {
        type: Sequelize.STRING,
        allowNull: false
      },
      normal_price: {
        type: Sequelize.DECIMAL,
        allowNull: false
      },
      harga_promo: {
        type: Sequelize.DECIMAL,
        allowNull: true
      },
      stock: {
        type: Sequelize.INTEGER,
        allowNull: false
      },
      created_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      },
      updated_at: {
        allowNull: false,
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW')
      }
    });
  },
  down: async (queryInterface, Sequelize) => {
    await queryInterface.dropTable('products');
  }
};
