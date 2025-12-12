import 'dotenv/config';

const config = {
	env: process.env.NODE_ENV || 'development',
	port: process.env.PORT || 3000,

	// maptiler: {
	// 	apiKey: process.env.MAP_TILER_API_KEY,
	// 	baseURL: process.env.MAP_TILER_BASE_URL
	// },

	tagsExtraction: {
		baseURL: process.env.TAGS_EXTRACTION_BASE_URL
	},

	openStreetMap: {
		baseURL: process.env.OPEN_STREET_MAP_BASE_URL
	},

	openRouteService: {
		baseURL: process.env.OPEN_ROUTE_SERVICE_BASE_URL,
		APIKey: process.env.OPEN_ROUTE_SERVICE_API_KEY
	},

	pythonBackend: {
		baseURLVan: process.env.PYTHON_BACKEND_VAN_BASE_URL,
		baseURLImageVan: process.env.PYTHON_BACKEND_IMAGE_VAN_BASE_URL,
		baseURLAn: process.env.PYTHON_BACKEND_AN_BASE_URL
	},

	discord: {
		webhook: process.env.WEBHOOK_LINK
	},

	cors: {
		allowedOrigins: process.env.ALLOWED_ORIGINS ? process.env.ALLOWED_ORIGINS.split(',') : ['http://localhost:3000']
	},

	rateLimit: {
		windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000,
		max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100
	},

	gemini: {
		APIKey: process.env.GEMINI_API_KEY,
	}
};

export default config;