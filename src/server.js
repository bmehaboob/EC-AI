const express = require('express');
const cors = require('cors');
const dotenv = require('dotenv');
const ecRoutes = require('./routes/ecRoutes');
const { pool } = require('./config/db');

dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
const corsOptions = {
  origin: process.env.CORS_ORIGIN ? process.env.CORS_ORIGIN.split(',') : '*', // Allow all if not set, or specific list
  optionsSuccessStatus: 200
};
app.use(cors(corsOptions));
app.use(express.json());

// Routes
app.use('/api/ec', ecRoutes);

// Database connection check
pool.query('SELECT NOW()', (err, res) => {
  if (err) {
    console.error('Database connection error:', err);
  } else {
    console.log('Database connected:', res.rows[0]);
  }
});

// Start server
app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
