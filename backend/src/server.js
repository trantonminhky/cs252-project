// IF YOU ARE USING AI TOOLS, MAKE SURE TO SET INDENTATION TO 4 SPACES INSTEAD OF 2 SPACES

// library imports
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');

// local imports
const config = require('./config/config');
const corsMiddleware = require('./middleware/cors');
const errorHandler = require('./middleware/errorHandler');

// route imports
const mapRoutes = require('./routes/mapRoutes');
const AIRoutes = require('./routes/AIRoutes');
const geocodeRoutes = require('./routes/geocodeRoutes');

const app = express();

// Security middleware
app.use(helmet())

// Rate limiting
const limiter = rateLimit({
	windowMs: config.rateLimit.windowMs,
	max: config.rateLimit.max,
	message: 'Too many requests from this IP, please try again later.'
});
app.use('/api/', limiter);

// CORS
app.use(corsMiddleware);

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Logging
if (config.env === 'development') {
	app.use(morgan('dev'));
}
else {
	app.use(morgan('combined'));
}

// Health check endpoint
app.get('/health', (req, res) => {
	res.json({
		success: true,
		message: 'Smart Tourism API is running',
		timestamp: new Date().toISOString(),
		environment: config.env
	});
});

// API route
app.use('/api/map', mapRoutes);
app.use('/api/geocode', geocodeRoutes);
app.use('/api/ai', AIRoutes);

// Root endpoint
app.get('/', (req, res) => {
	res.json({
		success: true,
		message: 'Welcome to Smart Tourism API',
		version: '1.0.0',
		endpoints: {
			health: '/health',

			geocode: '/api/geocode/geocode?address=<address>',
			reverseGeocode: '/api/geocode/reverse-geocode?lat=<lat>&lon=<lon>',

			mapConfig: '/api/map/config',
			route: '/api/map/route (POST)',
			searchNearby: '/api/map/search/nearby?lat=<lat>&lon=<lon>&radius=<radius>',
			tourismSpots: '/api/map/tourism-spots',
			tourismSpotsNearby: '/api/map/tourism-spots/nearby?lat=<lat>&lon=<lon>&radius=<radius>',
			staticMap: '/api/map/static-map?lat=<lat>&lon=<lon>',

			login: '/profile/login?username=<username>&password=<password>',
			register: '/profile/register?username=<username>&password=<password>',

			ask: '/api/ai/ask?prompt=<prompt>'
		}
	});
});

// 404 handler
app.use((req, res) => {
	res.status(404).json({
		success: false,
		error: { message: 'Route not found' }
	});
});

// Error handling middleware
app.use(errorHandler);

// Start server
const PORT = config.port;
app.listen(PORT, () => {
	console.log(`1. Server is running on port ${PORT}`);
	console.log(`2. Environment: ${config.env}`);
	console.log(`3. Map tiles ready with OpenMapTiles`);
	console.log(`\n API Docummentation: http://localhost:${PORT}/`)
});

module.exports = app;
