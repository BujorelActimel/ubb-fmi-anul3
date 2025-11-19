const { spawn } = require('child_process');
const config = require('../config.json');

process.env.API_URL = config.serverUrl;

spawn('npx', ['expo', 'start'], {
  stdio: 'inherit',
  env: process.env,
});
