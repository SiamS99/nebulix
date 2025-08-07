import request from 'supertest';
import express from 'express';
import apiRoutes from '../routes/api';

const app = express();
app.use('/api', apiRoutes);

describe('API No version Endpoint', () => {
  it('should return the API no version found message', async () => {
    const res = await request(app).get('/api');
    expect(res.statusCode).toBe(404);
    expect(res.body).toEqual({ error: 'Not Found missing API version' });
  });
});
