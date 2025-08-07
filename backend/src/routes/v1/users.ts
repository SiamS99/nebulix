import express from 'express';
const router = express.Router();

router.get('/', (req, res) => {
  res.json({users :[
    { id: 1, name: 'Alice' },
    { id: 2, name: 'Bob' }
  ]});
});

export default router;