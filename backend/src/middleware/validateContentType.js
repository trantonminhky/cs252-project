import ServiceResponse from "../helper/ServiceResponse";

function validateContentType(req, res, next) {
	if (req.headers['content-type'] !== 'application/json') {
		const response = new ServiceResponse(
			false,
			415,
			'Malformed Content-Type header'
		);
		return void res.status(response.statusCode).json(response.get());
	}
	next();
}

export default validateContentType;