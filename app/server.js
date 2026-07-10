const express = require('express');
const winston = require('winston');

// Structured logging
const logger = winston.createLogger({
  level: 'info',
  format: winston.format.combine(
    winston.format.timestamp(),
    winston.format.json()
  ),
  transports: [new winston.transports.Console()]
});

const app = express();
const PORT = process.env.PORT || 3000;

// Request logging middleware
app.use((req, res, next) => {
  logger.info({
    message: 'Incoming request',
    method: req.method,
    path: req.path,
    userAgent: req.get('user-agent'),
    ip: req.ip
  });
  next();
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    version: process.env.npm_package_version || '1.0.0',
    uptime: process.uptime()
  });
});

// API endpoint
app.get('/api/status', (req, res) => {
  logger.info('Status endpoint called');
  res.json({
    service: 'devsecops-platform',
    environment: process.env.NODE_ENV || 'development',
    region: process.env.AWS_REGION || 'unknown'
  });
});

// Simulate load for testing
app.get('/api/load/:duration', (req, res) => {
  const duration = parseInt(req.params.duration) || 100;
  const start = Date.now();

  // CPU-intensive operation (for load testing)
  while (Date.now() - start < duration) {
    Math.random() * Math.random();
  }

  res.json({
    message: 'Load test complete',
    duration: Date.now() - start
  });
});

// Error endpoint (for testing alerts)
app.get('/api/error', (req, res) => {
  logger.error('Simulated error endpoint called');
  res.status(500).json({ error: 'Simulated server error' });
});

// Global error handler
app.use((err, req, res, next) => {
  logger.error({
    message: 'Unhandled error',
    error: err.message,
    stack: err.stack
  });
  res.status(500).json({ error: 'Internal server error' });
});

// Add something like:
app.get('/api/hello', (req, res) => res.json({message: 'Hello from CI/CD!'}))

app.listen(PORT, '0.0.0.0', () => {
  logger.info(`Server running on port ${PORT}`);
});
