const ActivityLog = require('../models/activityLog');

async function logActivity({ userId, action, details }) {
  try {
    // Validasi userId tidak boleh null atau undefined
    if (!userId) {
      console.error('Error: userId is required for activity log');
      return;
    }

    await ActivityLog.create({
      userid: userId,  // Map userId parameter ke userid field di model
      action,
      details,
      timestamp: new Date()
    });
    
    console.log(`Activity logged: ${action} by user ${userId}`);
  } catch (err) {
    console.error('Gagal mencatat log aktivitas:', err);
  }
}

module.exports = logActivity;
