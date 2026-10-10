const express = require('express');
const rateLimit = require('express-rate-limit');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 3000;

// Trust proxy settings (vital if running behind Nginx, Heroku, or Cloudflare)
app.set('trust proxy', 1);

// ==========================================
// 1. Global API Rate Limiter (General Protection)
// ==========================================
const globalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes window
  max: 100,                 // Limit each IP to 100 requests per windowMs
  standardHeaders: true,    // Return rate limit info in `RateLimit-*` headers
  legacyHeaders: false,     // Disable old `X-RateLimit-*` headers
  message: {
    status: 429,
    success: false,
    message: 'Too many requests from this IP, please try again after 15 minutes.'
  }
});

// Apply global limiter to all routes starting with /api/
app.use('/api/', globalLimiter);

// ==========================================
// 2. Strict Login Rate Limiter (Advanced)
// ==========================================
const loginLimiter = rateLimit({
  windowMs: 1 * 60 * 1000, // 1 minute window
  max: 3,                  // Limit to 3 failed attempts
  standardHeaders: true,
  legacyHeaders: false,

  // Custom Key Generator: Tracks both IP AND the attempted username.
  // This prevents one user from locking out others on a shared network/IP.
  keyGenerator: (req) => {
    const username = req.body.username || 'anonymous';
    return `${req.ip}_${username}`;
  },

  // Skip Function: Whitelist internal testing or trusted tools via a custom header token
  skip: (req) => {
    const bypassToken = req.headers['x-internal-bypass-token'];
    return bypassToken === 'my-secret-internal-token-xyz';
  },

  // Custom Handler: Executes custom logic when the limit is breached (e.g., security audits)
  handler: (req, res, next, options) => {
    console.warn(`[SECURITY ALERT] Brute-force attempt detected! IP: ${req.ip}, Username: ${req.body.username || 'N/A'}`);

    res.status(options.statusCode).json({
      status: 429,
      success: false,
      message: options.message.message,
      retryAfterSeconds: Math.ceil(options.windowMs / 1000)
    });
  },

  message: {
    success: false,
    message: 'Too many login attempts. Account temporarily locked for 1 minute.'
  }
});

// ==========================================
// 3. API Routes
// ==========================================

// Standard health check route
app.get('/api/status', (req, res) => {
  res.json({
    success: true,
    status: 'Server is running securely with multi-tier rate limiting.'
  });
});

// Advanced login route protected by loginLimiter
app.post('/api/login', loginLimiter, (req, res) => {
  const { username, password } = req.body;

  // Basic validation
  if (!username || !password) {
    return res.status(400).json({
      success: false,
      message: 'Username and password are required fields.'
    });
  }

  // Mock authentication check
  if (username === 'admin' && password === '123456') {
    return res.json({
      success: true,
      message: 'Logged in successfully!',
      token: 'mock-jwt-auth-token-987654'
    });
  }

  return res.status(401).json({
    success: false,
    message: 'Invalid username or password.'
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`Advanced Express Server running at: http://localhost:${PORT}`);
});