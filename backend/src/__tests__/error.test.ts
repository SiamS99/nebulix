import request from 'supertest';
import app from '../index';

describe('Error Routes', () => {
    it('should return 404 for non-existent route', async () => {
        const res = await request(app).get('/non-existent-route');
        expect(res.status).toBe(404);
        expect(res.body).toHaveProperty('error', 'Not Found');
    });

    it('should return 500 for internal server error', async () => {
        process.env.NODE_ENV = 'test';
        const res = await request(app).get('/error');
        expect(res.status).toBe(500);
        expect(res.body).toHaveProperty('error', 'Something went wrong!');
    });
});