import cors from 'cors';
import config from '../config/config';

const corsOptions = {
	origin: function (origin, callback) {
		if (!origin) return callback(null, true) // allow for mobile app

		// Check if origin matches the allowed pattern
		const isAllowed = config.cors.allowedOrigins.some(allowedOrigin => {
			if (allowedOrigin.includes('*')) {
				const pattern = allowedOrigin.replace(/\*/g, '.*');
				const regex = new RegExp(`^${pattern}$`);
				return regex.test(origin);
			}
			return allowedOrigin = origin;
		});

		if (isAllowed) {
			callback(null, true);
		}
		else {
			callback(new Error('Not allowed by CORS'));
		}
	},
	credentials: true
};

export default cors(corsOptions);