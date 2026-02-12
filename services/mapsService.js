/**
 * NexusOMS - Google Maps Service
 * Distance calculation using Google Maps Distance Matrix API
 */

const { Client } = require('@googlemaps/google-maps-services-js');

// Initialize Google Maps client
let mapsClient;
let isConfigured = false;

if (process.env.GOOGLE_MAPS_API_KEY && !process.env.GOOGLE_MAPS_API_KEY.includes('your-google')) {
    mapsClient = new Client({});
    isConfigured = true;
    console.log('✅ Google Maps API initialized');
} else {
    console.warn('⚠️  Google Maps API key not configured. Using fallback distance calculation.');
}

/**
 * Get distance between two locations using Google Maps Distance Matrix API
 * @param {string} origin - Origin address or coordinates
 * @param {string} destination - Destination address or coordinates
 * @returns {Promise<Object>} Distance and duration data
 */
async function getDistance(origin, destination) {
    if (!isConfigured || !mapsClient) {
        console.log('📍 Google Maps not configured, using fallback');
        return null;
    }

    try {
        const response = await mapsClient.distancematrix({
            params: {
                origins: [origin],
                destinations: [destination],
                key: process.env.GOOGLE_MAPS_API_KEY,
                units: 'metric',
                mode: 'driving'
            },
            timeout: 5000 // 5 second timeout
        });

        if (response.data.status !== 'OK') {
            console.error('Google Maps API error:', response.data.status);
            return null;
        }

        const element = response.data.rows[0]?.elements[0];

        if (!element || element.status !== 'OK') {
            console.error('Distance calculation failed:', element?.status);
            return null;
        }

        const distanceInMeters = element.distance.value;
        const distanceInKm = (distanceInMeters / 1000).toFixed(2);
        const durationText = element.duration.text;
        const durationInMinutes = Math.round(element.duration.value / 60);

        console.log(`✅ Google Maps: ${origin} → ${destination} = ${distanceInKm} km`);

        return {
            distance: parseFloat(distanceInKm),
            distanceText: element.distance.text,
            duration: durationInMinutes,
            durationText: durationText,
            source: 'google_maps'
        };

    } catch (error) {
        console.error('Google Maps API error:', error.message);

        // Handle specific errors
        if (error.response?.status === 429) {
            console.error('⚠️  Google Maps API quota exceeded');
        } else if (error.response?.status === 403) {
            console.error('⚠️  Google Maps API key invalid or restricted');
        }

        return null;
    }
}

/**
 * Calculate distance using Haversine formula (fallback)
 * @param {number} lat1 - Origin latitude
 * @param {number} lon1 - Origin longitude
 * @param {number} lat2 - Destination latitude
 * @param {number} lon2 - Destination longitude
 * @returns {number} Distance in kilometers
 */
function calculateHaversineDistance(lat1, lon1, lat2, lon2) {
    const R = 6371; // Earth's radius in km
    const dLat = toRadians(lat2 - lat1);
    const dLon = toRadians(lon2 - lon1);

    const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
        Math.cos(toRadians(lat1)) * Math.cos(toRadians(lat2)) *
        Math.sin(dLon / 2) * Math.sin(dLon / 2);

    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    const distance = R * c;

    return parseFloat(distance.toFixed(2));
}

/**
 * Convert degrees to radians
 * @param {number} degrees
 * @returns {number} Radians
 */
function toRadians(degrees) {
    return degrees * (Math.PI / 180);
}

/**
 * Estimate duration based on distance (fallback)
 * @param {number} distanceKm - Distance in kilometers
 * @returns {number} Estimated duration in minutes
 */
function estimateDuration(distanceKm) {
    // Assume average speed of 40 km/h in city, 60 km/h on highway
    const avgSpeed = distanceKm > 50 ? 60 : 40;
    return Math.round((distanceKm / avgSpeed) * 60);
}

module.exports = {
    getDistance,
    calculateHaversineDistance,
    estimateDuration
};
