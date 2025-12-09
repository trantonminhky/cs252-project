// src/services/geocode/geocode.js
import axios from 'axios';

import ServiceResponse from '../helper/ServiceResponse.js';
import config from '../config/config.js';
import CacheDB from '../db/CacheDB.js';

const GEOCODE_CACHE_LIFETIME_MS = 86400000; // 1 day

/**
 * Geocode service provider class.
 * @class
 */
class GeocodeService {
	constructor() {
		this.baseUrl = config.openStreetMap.baseURL;
	}

	/**
	 * Service function for <code>/api/geocode/geocode</code>. Sends address to OpenStreetMap to return address' latitude and longitude. Supports <code>GET</code> requests.
	 * @param {string} address - Address to query OpenStreetMap
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl --header 'Authorization:Bearer MIKU_MIKU_OO_EE_OO' \
	 * http://localhost:3000/api/geocode/geocode?query=227%20nguyen%20van%20cu
	 * 
	 * @example <caption>Response</caption>
	 * {
     *	"success": true,
     *	"statusCode": 200,
     *	"payload": {
     *		"message": "Success (OK)",
     *		"data": [
     *			{
     *				"place_id": 239503968,
     *				"licence": "Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright",
     *				"osm_type": "way",
     *				"osm_id": 140703186,
     *				"lat": "10.7625844",
     *				"lon": "106.6816948",
     *				"category": "amenity",
     *				"type": "university",
     *				"place_rank": 30,
     *				"importance": 0.30544692142489355,
     *				"addresstype": "amenity",
     *				"name": "Trường Đại học Khoa học Tự nhiên - ĐHQG Thành phố Hồ Chí Minh - Cơ sở 1",
     *				"display_name": "Trường Đại học Khoa học Tự nhiên - ĐHQG Thành phố Hồ Chí Minh - Cơ sở 1, 227, Nguyễn Văn Cừ, Khu phố 5, Phường Cầu Ông Lãnh, Thủ Đức, Thành phố Hồ Chí Minh, 70000, Việt Nam",
     *				"boundingbox": [
     *					"10.7615770",
     *					"10.7632125",
     *					"106.6806370",
     *					"106.6827575"
     *				]
     *			}
     *		]
     *	}
 	 * }
	 * 
	 * @property {OK} 200 - Successful request
	 * @property {BAD_REQUEST} 400 - Missing address
	 * @property {UNAUTHORIZED} 401 - No bearer JWT was specified, or the JWT verification failed (invalid or expired)
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
	 * @property {BAD_GATEWAY} 502 - Something went wrong with the upstream APIs (cooked). <b>There is a known bug that if you send too many geocode requests, OSM will block you and throw 502</b>
	 */
	async geocode(address) {
		const cache = CacheDB.findGeocode(address);

		if (cache && Date.now() - cache.createdAt < GEOCODE_CACHE_LIFETIME_MS) {
			// if the result is already stored in cache and hasn't expired
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				cache.data
			);
			return response;
		}

		try {
			const url = `${this.baseUrl}/search`;
			const axiosResponse = await axios.get(url, {
				params: {
					format: 'jsonv2',
					q: address
				}
			});

			CacheDB.upsertGeocode({
				address: address,
				data: axiosResponse.data,
				createdAt: Date.now()
			});

			const response = new ServiceResponse(
				true,
				200,
				"Success",
				axiosResponse.data
			);
			return response;
		} catch (err) {
			const response = new ServiceResponse(
				false,
				502,
				"Something went wrong",
				err.toString()
			);
			return response;
		}
	}

	/**
	 * Service function for <code>/geocode/reverse-geocode</code>Sends latitude and longitude to OpenStreetMap to get reverse-geocoded address. Supports <code>GET</code> requests.
	 * @param {Number} lat - Latitude
	 * @param {Number} lon - Longitude
	 * @returns {Promise<ServiceResponse>}
	 * 
	 * @example <caption>cURL</caption>
	 * curl --header 'Authorization:Bearer MIKU_MIKU_OO_EE_OO' \
	 * http://localhost:3000/api/geocode/reverse-geocode?lat=10.762047\&lon=106.681832
	 * 
	 * @example <caption>Response</caption>
	 * {
     *	"success": true,
     *	"statusCode": 200,
     *	"payload": {
     *		"message": "Success (OK)",
     *		"data": {
     *			"place_id": 237412673,
     *			"licence": "Data © OpenStreetMap contributors, ODbL 1.0. http://osm.org/copyright",
     *			"osm_type": "node",
     *			"osm_id": 6791076694,
     *			"lat": "10.7621817",
     *			"lon": "106.6827205",
     *			"category": "place",
     *			"type": "house",
     *			"place_rank": 30,
     *			"importance": 0.00006703364614323671,
     *			"addresstype": "place",
     *			"name": "",
     *			"display_name": "221, Đường Nguyễn Văn Cừ, Phường Chợ Quán, Thủ Đức, Thành phố Hồ Chí Minh, 72406, Việt Nam",
     *			"address": {
     *				"house_number": "221",
     *				"road": "Đường Nguyễn Văn Cừ",
     *				"suburb": "Phường Chợ Quán",
     *				"city": "Thủ Đức",
     *				"ISO3166-2-lvl4": "VN-SG",
     *				"postcode": "72406",
     *				"country": "Việt Nam",
     *				"country_code": "vn"
     *			},
     *			"boundingbox": [
     *			"10.7621317",
     *			"10.7622317",
     *			"106.6826705",
     *			"106.6827705"
     *			]
     *		}
     * 	}
 	 * }
	 * 
	 * @property {OK} 200 - Successful request
	 * @property {BAD_REQUEST} 400 - Missing lat or lon
	 * @property {UNAUTHORIZED} 401 - No bearer JWT was specified, or the JWT verification failed (invalid or expired)
	 * @property {METHOD_NOT_ALLOWED} 405 - The endpoint does not support the HTTP method specified
	 * @property {INTERNAL_SERVER_ERROR} 500 - Something went wrong with the backend (cooked)
	 * @property {BAD_GATEWAY} 502 - Something went wrong with the upstream APIs (cooked). <b>There is a known bug that if you send too many reverse geocode requests, OSM will block you and throw 502</b>
	 */

	async reverseGeocode(lat, lon) {
		const cache = CacheDB.findReverseGeocode(lat, lon);

		if (cache && Date.now() - cache.createdAt < GEOCODE_CACHE_LIFETIME_MS) {
			const response = new ServiceResponse(
				true,
				200,
				"Success",
				cache.data
			);
			return response;
		}
		
		try {
			const url = `${this.baseUrl}/reverse`;
			const axiosResponse = await axios.get(url, {
				params: {
					format: 'jsonv2',
					lat: lat,
					lon: lon
				}
			});

			CacheDB.upsertReverseGeocode({
				lat: lat,
				lon: lon,
				data: axiosResponse.data,
				createdAt: Date.now()
			});

			const response = new ServiceResponse(
				true,
				200,
				"Success",
				axiosResponse.data
			);
			return response;
		} catch (err) {
			console.error(err);
			const response = new ServiceResponse(
				false,
				502,
				'Something went wrong',
				err.toString()
			);
			return response;
		}
	}
}

export default new GeocodeService();