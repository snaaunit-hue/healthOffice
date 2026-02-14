package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ye.gov.sanaa.healthoffice.entity.Facility;
import ye.gov.sanaa.healthoffice.repository.FacilityRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class GISService {

    private final FacilityRepository facilityRepository;

    private static final double EARTH_RADIUS = 6371000; // meters

    public double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        double dLat = Math.toRadians(lat2 - lat1);
        double dLon = Math.toRadians(lon2 - lon1);
        double a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
                Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2)) *
                        Math.sin(dLon / 2) * Math.sin(dLon / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return EARTH_RADIUS * c;
    }

    public boolean isLocationValid(Double lat, Double lon, String facilityType, double minDistanceMeters) {
        if (lat == null || lon == null)
            return true; // Skip if no location provided (or handle as error)

        // For high efficiency with large datasets, this should be a PostGIS/Spatial
        // query.
        // For this project scope, fetching list is acceptable if N is small (<10000).
        // Optimization: Filter by bounding box in DB first if added to Repo.

        List<Facility> facilities = facilityRepository.findByFacilityType(facilityType);

        for (Facility f : facilities) {
            if (f.getLatitude() != null && f.getLongitude() != null) {
                double distance = calculateDistance(lat, lon, f.getLatitude(), f.getLongitude());
                if (distance < minDistanceMeters) {
                    return false; // Too close
                }
            }
        }
        return true;
    }
}
