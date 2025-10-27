const express = require('express');
const mongoose = require('mongoose');
const app = express();

const PORT = process.env.PORT || 3000;
const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/testdb';
const ENV = process.env.ENVIRONMENT || 'dev';

mongoose.connect(MONGO_URI)
  .then(() => console.log(`✅ Connected to MongoDB: ${MONGO_URI}`))
  .catch(err => console.error('❌ MongoDB connection error:', err));

app.get('/', (req, res) => {
  res.json({ message: 'Hello from Node.js ECS App!', environment: ENV });
});

app.listen(PORT, () => {
  console.log(`🚀 App running on port ${PORT}`);
});
