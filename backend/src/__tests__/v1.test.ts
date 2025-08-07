import request from 'supertest';
import express from 'express';
import v1Router from '../routes/v1';

const app = express();
app.use('/api/v1', v1Router);

describe('API v1 Root Endpoint', () => {
  it('should return the API v1 root message', async () => {
    const res = await request(app).get('/api/v1');
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ message: 'API v1 root endpoint' });
  });
});
