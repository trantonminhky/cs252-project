import ServiceResponse from '../helper/ServiceResponse.js';
import mapService from '../services/MapService.js';

// TO-DO: DOCUMENT CONTROLLER CLASSES
// Sample spots (replace with database later)
const tourismSpots = [
    {
        id: 1,
        name: 'Historic Temple',
        description: 'A beautifil ancient temmple with stunning architecture',
        lat: 10.762622,
        lon: 106.660172,
        category: 'temple',
        rating: 4.5,
        image: []
    },
    {
        id: 2,
        name: 'Central Park',
        description: 'Large urban park perfect for relaxation',
        lat: 10.773996,
        lon: 106.697536,
        category: 'park',
        rating: 4.2,
        images: []
    },
    {
        id: 3,
        name: 'City Museum',
        description: 'Museum showcasing local history and culture',
        lat: 10.779160,
        lon: 106.695881,
        category: 'museum',
        rating: 4.7,
        image: []
    }
];

class MapController {
    // Get route between points
    async getRoute(req, res, next) {
        try {
            const { coordinates, profile } = req.body;

			if (!coordinates) {
				const response = new ServiceResponse(
					false,
					400,
					"Coordinates are required"
				);
				return res.status(response.statusCode).json(response.get());
			}

			if (!Array.isArray(coordinates)) {
				const response = new ServiceResponse(
					false,
					400,
					"Coordinates must be expressed as an array of 2 coordinate pairs"
				);
				return res.status(response.statusCode).json(response.get());
			}

            if (coordinates.length != 2) {
				const response = new ServiceResponse(
					false,
					400,
					"Only two pairs of coordinates must be specified"
				);
				return res.status(response.statusCode).json(response.get());
            }

            const response = await mapService.getRoute(coordinates, profile);
            res.status(response.statusCode).json(response.get());
        } catch (error) {
            next(error);
        }
    }

    // Search nearby place
    async nearby(req, res, next) {
        try {
            const lat = req.body.lat;
			const lon = req.body.lon;
			const radius = req.body.radius;
			const category_ids = req.body.category_ids;

            if (lat == null || lon == null) {
				const response = new ServiceResponse(
					false,
					400,
					"Latitude and longitude are required"
				);
				return res.status(response.statusCode).json(response.get());
			}
			
			const response = await mapService.nearby(lat, lon, radius, category_ids);
			res.status(response.statusCode).json(response.get());

        } catch (error) {
            next(error);
        }
    }
};

export default new MapController();