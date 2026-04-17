const express = require('express');
const router = express.Router();
const { sql, config } = require('../config/database');

router.get('/', async (req, res) => {
  try {
    const pool = await sql.connect(config);
    const result = await pool.request().query('SELECT * FROM Products');
    res.render('products', { title: 'Products', products: result.recordset });
  } catch (err) {
    console.error('Database error:', err);
    res.status(500).send('Error loading products');
  }
});

module.exports = router;
