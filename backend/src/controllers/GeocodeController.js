import geocodeService from '../services/GeocodeService.js';
import ServiceResponse from '../helper/ServiceResponse.js';

// TO-DO: DOCUMENT CONTROLLER CLASSES
class GeocodeController {
	// Geocode an address
	async geocode(req, res, next) {
		try {
			const { address } = req.query;
			// if no address is specified
			if (!address) {
				const response = new ServiceResponse(
					false,
					400,
					"Address parameter is required"
				);

				return res.status(response.statusCode).json(response.get());
			}

			const response = await geocodeService.geocode(address);
			return void res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}

	// Reverse geocode coordinates
	async reverseGeocode(req, res, next) {
		try {
			const { lat, lon } = req.query;
			if (lat == null || lon == null) {
				const response = new ServiceResponse(
					false,
					400,
					`Latitude and longitude parameters are required`
				);

				return res.status(response.statusCode).json(response.get());
			}

			const response = await geocodeService.reverseGeocode(parseFloat(lat), parseFloat(lon));

			res.status(response.statusCode).json(response.get());
		} catch (error) {
			next(error);
		}
	}
}

export default new GeocodeController();