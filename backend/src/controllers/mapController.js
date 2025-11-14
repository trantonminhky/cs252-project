const mapService = require('../services/mapService');
const geocodeService = require('../services/geocode/geocode');

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
    // Get map tile config
    async getMapConfig(req, res, next) {
        try {
            const {style = 'streets'} = req.query;
            const config = mapService.getMapTileUrl(style);

            res.json({
                success: true,
                data: config
            });
        } catch (error) {
            next(error);
        }
    }

    // Geocode an address
    async geocode(req, res, next) {
        try {
            const {address} = req.query;

            if (!address) {
                return res.status(400).json({
                    success: false,
                    error: {message: 'Address parameter is required'}
                });
            }

            const result = await geocodeService.geocode(address);

            res.json({
                success: true,
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    // Reverse geocode coordinates
    async reverseGeocode(req, res, next) {
        try {
            const {lat, lon} = req.query;

            if (!lat || !lon) {
                return res.status(400).json({
                    success: false,
                    error: {message: 'Latitude and longtitude parameters are required'}
                });
            }

            const result = await geocodeService.reverseGeocode(parseFloat(lat), parseFloat(lon));

            res.json({
                success: true,
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    // Get route between points
    async getRoute(req, res, next) {
        try {
            const {coordinates, profile = 'driving'} = req.body;

            if (!coordinates || !Array.isArray(coordinates) || coordinates.length < 2) {
                return res.status(400).json({
                    success: false,
                    error: {message: 'At least 2 coordinate pairs are required'}
                });
            }

            const result = await mapService.getRoute(coordinates, profile);

            res.json({
                success: true,
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    // Search nearby place
    async searchNearby(req, res, next) {
        try {
            const {lat, lon,  radius = 5000, category} = req.query;

            if (!lat || !lon) {
                return res.status(400).json({
                    success: false,
                    error: {message: 'Latuitude and longtitude parameters are required'}
                });
            }

            const result = await mapService.searchNearBy(
                parseFloat(lat),
                parseFloat(lon),
                parseInt(radius),
                category
            );

            res.json({
                success: true,
                data: result
            });
        } catch (error) {
            next(error);
        }
    }

    // Get all tourism spots
    async getTourismSpots(req, res, next) {
        try {
            const {category, minRating} = req.query;

            let filteredSpots = [...tourismSpots];

            if (category) {
                filteredSpots = filteredSpots.filter(spot => spot.category === category);
            }

            if (minRating) {
                filteredSpots = filteredSpots.filter(spot => spot.rating >= parseFloat(minRating));
            }

            res.json({
                success: true,

                data: filteredSpots,
                count: filteredSpots.length
            });
        } catch (error) {
            next(error);
        }
    }

    // Get a single tourism spot by ID
    async getTourismSpotById(req, res, next) {
        try {
        const { id } = req.params;
        const spot = tourismSpots.find(s => s.id === parseInt(id));
        
        if (!spot) {
            return res.status(404).json({
            success: false,
            error: { message: 'Tourism spot not found' }
            });
        }
        
        res.json({
            success: true,
            data: spot
        });
        } catch (error) {
        next(error);
        }
    }

    // Get tourism spots within a radius
    async getTourismSpotsNearby(req, res, next) {
        try {
        const { lat, lon, radius = 5 } = req.query;
        
        if (!lat || !lon) {
            return res.status(400).json({
            success: false,
            error: { message: 'Latitude and longitude parameters are required' }
            });
        }

        const userLat = parseFloat(lat);
        const userLon = parseFloat(lon);
        const searchRadius = parseFloat(radius);

        // Calculate distance using Haversine formula
        const calculateDistance = (lat1, lon1, lat2, lon2) => {
            const R = 6371; // Earth's radius in km
            const dLat = (lat2 - lat1) * Math.PI / 180;
            const dLon = (lon2 - lon1) * Math.PI / 180;
            const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                    Math.sin(dLon / 2) * Math.sin(dLon / 2);
            const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
            return R * c;
        };

        const nearbySpots = tourismSpots
            .map(spot => ({
            ...spot,
            distance: calculateDistance(userLat, userLon, spot.lat, spot.lon)
            }))
            .filter(spot => spot.distance <= searchRadius)
            .sort((a, b) => a.distance - b.distance);

        res.json({
            success: true,
            data: nearbySpots,
            count: nearbySpots.length
        });
        } catch (error) {
        next(error);
        }
    }

    // Get static map image URL
    async getStaticMap(req, res, next) {
        try {
          const { lat, lon, zoom = 14, width = 600, height = 400 } = req.query;
          
          if (!lat || !lon) {
            return res.status(400).json({
              success: false,
              error: { message: 'Latitude and longitude parameters are required' }
            });
          }
    
          const imageUrl = mapService.getStaticMapUrl(
            parseFloat(lat),
            parseFloat(lon),
            parseInt(zoom),
            parseInt(width),
            parseInt(height)
          );
          
          res.json({
            success: true,
            data: { imageUrl }
          });
        } catch (error) {
          next(error);
        }
    }
};

module.exports = new MapController();