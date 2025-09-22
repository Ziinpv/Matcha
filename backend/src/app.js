const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { verifyJwtMiddleware } = require('./utils/jwt');

// Routes
const authRoutes = require('./routes/auth.routes');
const userRoutes = require('./routes/user.routes');
const matchRoutes = require('./routes/match.routes');
const chatRoutes = require('./routes/chat.routes');
const blockRoutes = require('./routes/block.routes');

const app = express();

app.use(cors());
app.use(bodyParser.json({ limit: '10mb' }));
app.use(bodyParser.urlencoded({ extended: true }));

// Health check
app.get('/health', (_req, res) => {
  res.json({ ok: true });
});

// Public routes (no JWT required)
app.use('/api/auth', authRoutes);

// Protected routes (JWT required)
app.use(verifyJwtMiddleware);
app.use('/api/user', userRoutes);
app.use('/api/match', matchRoutes);
app.use('/api/chat', chatRoutes);
app.use('/api/block', blockRoutes);

module.exports = app;


