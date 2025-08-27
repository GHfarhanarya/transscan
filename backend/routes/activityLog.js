const express = require('express');
const router = express.Router();
const { authenticateToken, authorizeRole } = require('../middleware/auth');
const ActivityLog = require('../models/activityLog');
const User = require('../models/user');

// Ambil semua log aktivitas (hanya admin)
router.get('/', authenticateToken, authorizeRole(['admin']), async (req, res) => {
  try {
    const logs = await ActivityLog.findAll({
      order: [['timestamp', 'DESC']],
      limit: 50,
      include: [{ model: User, attributes: ['name', 'employee_id', 'role'] }],
    });
    res.json(logs);
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

module.exports = router;
