require('dotenv').config();

const config = {
	env: process.env.NODE_ENV || 'development',
	port: process.env.PORT || 3000,

	maptiler: {
		apiKey: process.env.MAPTILER_API_KEY,
		baseUrl: 'https://api.maptiler.com'
	},

	openStreetMap: {
		baseUrl: 'https://nominatim.openstreetmap.org'
	},

	cors: {
		allowedOrigins: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['http://localhost:3000']
	},

	rateLimit: {
		windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
		max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100
	},

	gemini: {
		apiKey: process.env.GEMINI_API_KEY,
	}
};

module.exports = config;