import ServiceResponse from "../helper/ServiceResponse.js";

function errorHandler(err, req, res, next) {
	console.error(err);

	const response = new ServiceResponse(
		false,
		500,
		"Something went wrong",
		err.toString()
	);
	return void res.status(response.statusCode).json(response.get());
}

export default errorHandler;