const express = require('express');
const router = express.Router();

// Example route: GET /api/
router.get('/', (req, res) => {
  res.json({ message: 'API root endpoint' });
});

// Example route: GET /api/health
router.get('/health', (req, res) => {
  res.json({ status: 'OK' });
});

module.exports = router;