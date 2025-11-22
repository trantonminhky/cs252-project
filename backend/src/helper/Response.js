const friendlyHttpStatus = {
    '200': 'OK',
    '201': 'CREATED',
    '202': 'ACCEPTED',
    '203': 'NON_AUTHORITATIVE_INFORMATION',
    '204': 'NO_CONTENT',
    '205': 'RESET_CONTENT',
    '206': 'PARTIAL_CONTENT',
    '300': 'MULTIPLE_CHOICES',
    '301': 'MOVED_PERMANENTLY',
    '302': 'FOUND',
    '303': 'SEE_OTHER',
    '304': 'NOT_MODIFIED',
    '305': 'USE_PROXY',
    '306': 'UNUSED',
    '307': 'TEMPORARY_REDIRECT',
    '400': 'BAD_REQUEST',
    '401': 'UNAUTHORIZED',
    '402': 'PAYMENT_REQUIRED',
    '403': 'FORBIDDEN',
    '404': 'NOT_FOUND',
    '405': 'METHOD_NOT_ALLOWED',
    '406': 'NOT_ACCEPTABLE',
    '407': 'PROXY_AUTHENTICATION_REQUIRED',
    '408': 'REQUEST_TIMEOUT',
    '409': 'CONFLICT',
    '410': 'GONE',
    '411': 'LENGTH_REQUIRED',
    '412': 'PRECONDITION_REQUIRED',
    '413': 'REQUEST_ENTRY_TOO_LARGE',
    '414': 'REQUEST_URI_TOO_LONG',
    '415': 'UNSUPPORTED_MEDIA_TYPE',
    '416': 'REQUESTED_RANGE_NOT_SATISFIABLE',
    '417': 'EXPECTATION_FAILED',
    '418': 'IM_A_TEAPOT',
    '429': 'TOO_MANY_REQUESTS',
    '500': 'INTERNAL_SERVER_ERROR',
    '501': 'NOT_IMPLEMENTED',
    '502': 'BAD_GATEWAY',
    '503': 'SERVICE_UNAVAILABLE',
    '504': 'GATEWAY_TIMEOUT',
    '505': 'HTTP_VERSION_NOT_SUPPORTED',
};

/**
 * Service response representation.
 * @class
 */
class Response {
	/**
	 * Response constructor.
	 * @constructor
	 * @param {Boolean} success - Success status. Status code of 2xx generally indicates success = true
	 * @param {Number} statusCode - HTTP status code
	 * @param {String} message - Readable status code message
	 */
	constructor(success, statusCode, message, data=null) {
		this.success = success;
		this.statusCode = statusCode;
		this.payload = {
			message: message,
			data: data
		};
	}

	get() {
		return {
			success: this.success,
			statusCode: this.statusCode,
			payload: {
				message: `${message} (${friendlyHttpStatus[this.statusCode]})`,
				data: data
			}
		}
	}
}