import express from 'express';
import cors from 'cors';
import morgan from 'morgan';
import helmet from 'helmet';

import apiRoutes from './routes/api';

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(morgan('dev'));

// Routes
app.use('/api', apiRoutes);

// Test-only error route (for 500 error testing)
  app.get('/error', (req, res, next) => {
    next(new Error('Test error'));
  });

// 404 handler
app.use((req, res, next) => {
  res.status(404).json({ error: 'Not Found' });
});

// Error handler
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  res.status(500).json({ error: 'Something went wrong!' });
});

// Only start server if not in test mode
/* istanbul ignore next */
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

export default app;