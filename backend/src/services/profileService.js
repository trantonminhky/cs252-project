const axios = require('axios');
const config = require('../config/config');
const crypto = require('crypto');

const db = require('../db/LoginDB');

function generateToken32() {
	return crypto.randomBytes(24).toString('base64').slice(0, 32);
}

class ProfileService {
	async register(user, pass) {
		if (!user || !pass) {
			throw new Error('User or pass is required');
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

	async login(user, pass) {
		if (!user || !pass) {
			throw new Error('User or pass is required');
		}

		try {
			const response = {}
			const password = db.get(user, 'password');
			
			if (!password) {
				response.success = false;
				response.data = "NO_USER_FOUND";
			} else if (password !== pass) {
				response.success = false;
				response.data = "WRONG_PASSWORD";
			} else {
				response.success = true;
				response.data = generateToken32();
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
			return "Clear success";
		} catch (err) {
			console.error(err);
		}
	}
}

module.exports = new ProfileService();