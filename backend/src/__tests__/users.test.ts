import request from 'supertest';
import express from 'express';
import usersRouter from '../routes/v1/users';

const app = express();
app.use('/api/v1/users', usersRouter);

describe('API v1 Users Endpoint', () => {
  it('should return the API v1 users message', async () => {
    const res = await request(app).get('/api/v1/users');
    expect(res.statusCode).toBe(200);
    expect(res.body).toEqual({ users :[
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' }]});
  });
});
