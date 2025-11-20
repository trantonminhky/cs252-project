const axios = require('axios');
const config = require('../config/config');

const db = require('../db/LoginDB');

class ProfileService {
	async test_set(user) {
		if (!user) {
			throw new Error('User is required');
		}

		try {
			db.set('user', user);
			return "Success";
		} catch (err) {
			throw new Error("failed");
		}
	}

	async test_get(user) {
		if (!user) {
			throw new Error('User is required');
		}

		try {
			const response = {}
			if (!db.has(user)) {
				response.success = false;
				response.data = null;
			} else {
				const val = db.get(user);
				response.success = true;
				response.data = val;
			}
			
			return response;
		} catch (err) {
			throw new Error("failed");
		}
	}
}

module.exports = new ProfileService();