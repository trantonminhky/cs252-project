import http from 'http'

/**
 * Service response representation.
 * @class
 */
class ServiceResponse {
	/**
	 * Response constructor.
	 * @constructor
	 * @param {Boolean} success - Success status. Status code of 2xx generally indicates success = true
	 * @param {Number} statusCode - HTTP status code
	 * @param {String} message - Readable status code message
	 * @param {any} data - Data to be put into payload
	 */
	constructor(success, statusCode, message, data=null) {
		this.success = success;
		this.statusCode = statusCode;
		this.payload = {
			message: message,
			data: data
		};
	}

	/**
	 * Get Object representation of this.
	 * @returns {Object} Object
	 */
	get() {
		return {
			success: this.success,
			statusCode: this.statusCode,
			payload: {
				message: `${this.payload.message} (${http.STATUS_CODES[this.statusCode].toUpperCase().split(' ').join('_')})`,
				data: this.payload.data
			}
		}
	}
}

export default ServiceResponse;