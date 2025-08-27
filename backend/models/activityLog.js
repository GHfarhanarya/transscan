const { DataTypes } = require('sequelize');
const sequelize = require('../db');


const ActivityLog = sequelize.define('ActivityLog', {
  userId: {
    type: DataTypes.STRING(10), //sama seperti employee_id
    allowNull: false,
  },
  action: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  details: {
    type: DataTypes.TEXT,
    allowNull: true,
  },
  timestamp: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
});

const User = require('./user');
ActivityLog.belongsTo(User, { foreignKey: 'userId', targetKey: 'employee_id' });

module.exports = ActivityLog;
