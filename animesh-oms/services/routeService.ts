
import { DeliveryRoute, RouteStop, Vehicle, StopCoordinates } from '../types';

/**
 * Simulates a Vehicle Routing Problem (VRP) optimization using a Nearest-Neighbor approach.
 * Handles Multi-Depot starts, Multi-Stop sequences, and Capacity constraints.
 */
export async function optimizeRoute(
  stops: RouteStop[],
  startCoords: StopCoordinates,
  vehicle: Vehicle
): Promise<RouteStop[]> {
  // Simulate API Latency
  await new Promise(r => setTimeout(r, 1500));

  let currentPos = startCoords;
  let remainingStops = [...stops];
  let optimizedSequence: RouteStop[] = [];
  let currentLoadWeight = 0;
  let currentLoadVolume = 0;

  while (remainingStops.length > 0) {
    // Find closest stop that fits capacity
    let nearestIdx = -1;
    let minDistance = Infinity;

    for (let i = 0; i < remainingStops.length; i++) {
      const stop = remainingStops[i];
      
      // Basic distance simulation (Haversine-ish)
      const dist = Math.sqrt(
        Math.pow(stop.coords.lat - currentPos.lat, 2) + 
        Math.pow(stop.coords.lng - currentPos.lng, 2)
      );

      // Check capacity
      if (currentLoadWeight + stop.weightKg <= vehicle.capacityKg && 
          currentLoadVolume + stop.volumeCft <= vehicle.capacityCft) {
        if (dist < minDistance) {
          minDistance = dist;
          nearestIdx = i;
        }
      }
    }

    if (nearestIdx === -1) {
      // No more stops fit in this run, but we return the sequence found so far
      break;
    }

    const nextStop = remainingStops.splice(nearestIdx, 1)[0];
    currentPos = nextStop.coords;
    currentLoadWeight += nextStop.weightKg;
    currentLoadVolume += nextStop.volumeCft;
    
    optimizedSequence.push({
      ...nextStop,
      sequence: optimizedSequence.length + 1,
      distanceFromPrev: Math.round(minDistance * 111) // approx km conversion
    });
  }

  return optimizedSequence;
}

export const WAREHOUSE_COORDS: Record<string, StopCoordinates> = {
  'IOPL Kurla': { lat: 19.0728, lng: 72.8826 },
  'IOPL DP WORLD': { lat: 18.9482, lng: 72.9497 },
  'IOPL Arihant Delhi': { lat: 28.6139, lng: 77.2090 },
  'IOPL Jolly Bng': { lat: 12.9716, lng: 77.5946 }
};
