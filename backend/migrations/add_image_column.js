const sequelize = require('../db');
const { QueryTypes } = require('sequelize');

async function addImageColumn() {
  try {
    // Check if column exists
    const columns = await sequelize.query(
      "SHOW COLUMNS FROM products LIKE 'image'",
      { type: QueryTypes.SELECT }
    );

    if (columns.length === 0) {
      // Add image column if it doesn't exist
      await sequelize.query(
        "ALTER TABLE products ADD COLUMN image VARCHAR(500)"
      );
      console.log('Successfully added image column to products table');
    } else {
      console.log('Image column already exists');
    }
  } catch (error) {
    console.error('Error adding image column:', error);
  }
}

// Run the migration
addImageColumn()
  .then(() => {
    console.log('Migration completed');
    process.exit(0);
  })
  .catch(error => {
    console.error('Migration failed:', error);
    process.exit(1);
  });
