const ActivityLog = require('../models/activityLog');

async function logActivity({ userId, action, details }) {
  try {
    await ActivityLog.create({
      userId,
      action,
      details,
      timestamp: new Date()
    });
  } catch (err) {
    console.error('Gagal mencatat log aktivitas:', err);
  }
}

module.exports = logActivity;
