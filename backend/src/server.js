// IF YOU ARE USING AI TOOLS, MAKE SURE TO SET INDENTATION TO 4 SPACES INSTEAD OF 2 SPACES

// library imports
const express = require('express');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const morgan = require('morgan');
const exec = require('child_process').exec;

// local imports
const config = require('./config/config');
const corsMiddleware = require('./middleware/cors');
const errorHandler = require('./middleware/errorHandler');

// route imports
const MapRoutes = require('./routes/MapRoutes');
const AIRoutes = require('./routes/AIRoutes');
const GeocodeRoutes = require('./routes/GeocodeRoutes');
const ProfileRoutes = require('./routes/ProfileRoutes');
const DBRoutes = require('./routes/DBRoutes');
const LocationRoutes = require('./routes/LocationRoutes');

const app = express();
const customStream = {
	write: (message) => {
		console.log(message.trimEnd());
		const stripAnsi = (s) => s.replace(/\x1b\[[0-9;]*m/g, '');
		const clean = stripAnsi(message).trimEnd();
		exec(`./sendRequest.sh "${clean}"`);
	}
};

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
	app.use(morgan('dev', { stream: customStream }));
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
app.use('/api/map', MapRoutes);
app.use('/api/geocode', GeocodeRoutes);
app.use('/api/ai', AIRoutes);
app.use('/api/profile', ProfileRoutes);
app.use('/api/db', DBRoutes);
app.use('/api/location', LocationRoutes);

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

			register: '/api/profile/register (POST) body: { "username": "<user>", "password": "<pass>" }',
			login: '/api/profile/test-get?username=<user>&password=<pass>',

			ask: '/api/ai/ask?prompt=<prompt>',

			db: '/api/db/dangerous/get'
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
	// console.log(`1. Server is running on port ${PORT}`);
	// console.log(`2. Environment: ${config.env}`);
	// console.log(`3. Map tiles ready with OpenMapTiles`);
	// console.log(`\n API Docummentation: http://localhost:${PORT}/`)
	console.clear();
});

module.exports = app;