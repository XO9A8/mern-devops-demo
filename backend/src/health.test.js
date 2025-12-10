// backend/src/health.test.js
const request = require('supertest');

// Mock mongoose to prevent actual DB connection during tests
jest.mock('mongoose', () => ({
    connect: jest.fn().mockResolvedValue(true),
    connection: {
        readyState: 1
    }
}));

// Import app after mocking
const app = require('./server');

describe('Health Check Endpoint', () => {
    it('should return healthy status with 200', async () => {
        const res = await request(app).get('/health');
        expect(res.statusCode).toBe(200);
        expect(res.body).toHaveProperty('status', 'healthy');
        expect(res.body).toHaveProperty('timestamp');
        expect(res.body).toHaveProperty('uptime');
    });

    it('should return uptime as a number', async () => {
        const res = await request(app).get('/health');
        expect(typeof res.body.uptime).toBe('number');
        expect(res.body.uptime).toBeGreaterThanOrEqual(0);
    });
});

describe('API Root Endpoint', () => {
    it('should return welcome message', async () => {
        const res = await request(app).get('/api');
        expect(res.statusCode).toBe(200);
        expect(res.body).toHaveProperty('message', 'Welcome to MERN Demo API');
    });
});
