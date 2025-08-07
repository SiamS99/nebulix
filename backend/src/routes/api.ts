import express from 'express';
import v1Router from './v1';
const routes = express.Router();

routes.use('/v1', v1Router);

routes.get('/', (req, res) => {
  res.status(404).json({ error: 'Not Found missing API version' });
});

export default routes;