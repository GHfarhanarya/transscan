const ActivityLog = require('../models/activityLog');

async function logActivity({ userId, action, details }) {
  try {
    // Validasi userId tidak boleh null atau undefined
    if (!userId) {
      console.error('Error: userId is required for activity log');
      return;
    }

    const activityLog = await ActivityLog.create({
      userid: userId,  // Map userId parameter ke userid field di model
      action,
      details,
      timestamp: new Date()
    });
    
    console.log(`Activity logged: ${action} by user ${userId}`);
    
    // Emit real-time event ke semua client yang terhubung
    if (global.io) {
      const activityData = {
        id: activityLog.id,
        userid: activityLog.userid,
        action: activityLog.action,
        details: activityLog.details,
        timestamp: activityLog.timestamp
      };
      
      global.io.emit('newActivity', activityData);
      console.log('Real-time activity emitted:', activityData);
    }
    
    return activityLog;
  } catch (err) {
    console.error('Gagal mencatat log aktivitas:', err);
  }
}

module.exports = logActivity;
