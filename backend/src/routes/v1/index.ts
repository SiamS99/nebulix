import express from 'express';
import usersRouter from './users';
const router = express.Router();

router.use('/users', usersRouter);

router.get('/', (req, res) => {
  res.json({ message: 'API v1 root endpoint' });
});

export default router;