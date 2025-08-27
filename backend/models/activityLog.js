const { DataTypes } = require('sequelize');
const sequelize = require('../db');


const ActivityLog = sequelize.define('ActivityLog', {
  userid: {
    type: DataTypes.STRING(10),
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
}, {
  tableName: 'activitylogs',
  timestamps: false
});

const User = require('./user');
ActivityLog.belongsTo(User, { foreignKey: 'userid', targetKey: 'employee_id' });

module.exports = ActivityLog;
