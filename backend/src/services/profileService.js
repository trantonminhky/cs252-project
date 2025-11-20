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
}

module.exports = new ProfileService();