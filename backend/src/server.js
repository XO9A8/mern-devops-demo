// backend/src/server.js
const express = require('express');
const cors = require('cors');
const mongoose = require('mongoose');
const logger = require('./logger');

require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

// API routes
app.get('/api', (req, res) => {
    res.json({ message: 'Welcome to MERN Demo API' });
});

// TODO: Add your routes here
// app.use('/api/users', require('./routes/users'));
// app.use('/api/posts', require('./routes/posts'));

// Error handling
app.use((err, req, res, next) => {
    logger.error('Unhandled error', { error: err.message, stack: err.stack });
    res.status(500).json({ error: 'Internal server error' });
});

// Connect to MongoDB and start server
const startServer = async () => {
    try {
        await mongoose.connect(process.env.MONGO_URI);
        logger.info('Connected to MongoDB');

        app.listen(PORT, () => {
            logger.info(`Server running on port ${PORT}`);
        });
    } catch (error) {
        logger.error('Failed to start server', { error: error.message });
        process.exit(1);
    }
};

startServer();

module.exports = app;
