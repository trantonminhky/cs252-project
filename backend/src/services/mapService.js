const axios = require('axios');
const config = require('../config/config');

class MapService {
  constructor() {
    this.apiKey = config.maptiler.apiKey;
    this.baseUrl = config.maptiler.baseUrl;
  }

  // Get URL for displaying maps
  // param - Map style (streets, outdoor, satellite,...)
  // return - Tile URL and configuration
  getMapTileUrl(style = 'streets') {
    return {
      tilesUrl: `${this.baseUrl}/maps/${style}/{z}/{x}/{y}.png?key=${this.apiKey}`,
      attribution: 'MapTiler OpenStreetMap contributors',
      maxZoom: 18,
      minZoom: 0
    };
  }

  // Convert address to coordinates
  // param - Address or place name
  // return - Location data
  async geocode(query) {
    try {
      const response = await axios.get(`${this.baseUrl}/geocoding/${encodeURIComponent(query)}.json`, {
        params: {
          key: this.apiKey,
          limit: 5
        }
      });
      return response.data;
    } catch(error) {
      throw new Error(`Geocoding failed: ${error.message}`);
    }
  }

  // Convert coordinates to address
  // para - latitude, longtitude
  // return - address data
  async reverseGeocode(lat, lon) {
    try {
      const response = await axios.get(`${this.baseUrl}/geocoding/${lon},${lat}.json`, {
        params: {
          key: this.apiKey
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Reverse geocoding failed: ${error.message}`);
    }
  }

  // Get route between two points
  // param - array of [lon,lat] pairs
  // return - route data
  async getRoute(coordinates, profile = 'driving') {
    try {
      const coords = coordinates.map(c => `${c[0]},$c{[1]}`).json(';');
      const response = await axios.get(`${this.baseUrl}/routing/${profile}/${coords}.json`, {
        params: {
          key: this.apiKey,
          overview: 'full',
          steps: true
        }
      });
      return response.data;
    } catch (error) {
      throw new Error(`Routing failed: ${error.message}`);
    }
  }

  // Search for places near a location
  // params - lat, lon, rad, category
  // return - places data
  async searchNearBy(lat, lon, radius = 5000, category = null) {
    try {
      const params = {
        key: this.apiKey,
        lat,
        lon,
        radius,
        limit: 20
      };

      if (category) {
        params.types = category;
      }

      const response = await axios.get(`${this.baseUrl}/geocoding/nearby.json`, {
        params
      });

      return response.data;
    } catch (error) {
      throw new Error(`Nearby search failed: ${error.message}`);
    }
  }

  // Get static map image
  // params - lat, lon, zoom, width, height
  // return - image url
  getStaticMapUrl(lat, lon, zoom = 14, width = 600, height = 400) {
    return `${this.baseUrl}/maps/streets/static/${lon},${lat},${zoom},${width}x${height}.png?key=${this.apiKey}`;
  }  
}

module.exports = new MapService();