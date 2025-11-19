const axios = require('axios');
const config = require('../config/config');

// for some reason this only works on node even version number, i have no fucking idea why

let db;
import('enmap').then(async ({ default: Enmap }) => {
	db = new Enmap({ name: 'db' });
});

class ProfileService {
	async test(user) {
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