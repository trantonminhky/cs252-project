const axios = require('axios');
const config = require('../config/config');

const db = require('../db/LoginDB');

class ProfileService {
	async test_set(user, pass) {
		if (!user) {
			throw new Error('User is required');
		}

		try {
			db.set(user, {
				username: user,
				password: pass
			});
			return `Success (${db.get(user, 'username')} set to ${db.get(user, 'password')})`;
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
			console.log(db.get(user, 'password'))
			if (!db.get(user, 'password')) {
				response.success = false;
				response.data = null;
			} else {
				const val = db.get(user, 'password');
				response.success = true;
				response.data = val;
			}

			return response;
		} catch (err) {
			console.error(err);
			throw new Error("failed");
		}
	}

	async clear() {
		try {
			db.clear();
			return "Suceess";
		} catch (err) {
			console.error(err);
		}
	}
}

module.exports = new ProfileService();