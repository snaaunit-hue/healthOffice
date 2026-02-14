package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ye.gov.sanaa.healthoffice.dto.FacilityDto;
import ye.gov.sanaa.healthoffice.entity.Facility;
import ye.gov.sanaa.healthoffice.repository.FacilityRepository;

import java.util.UUID;

@Service
@RequiredArgsConstructor
public class FacilityService {

    private final FacilityRepository facilityRepository;
    private final GISService gisService;

    @Transactional
    public FacilityDto createFacility(FacilityDto dto) {
        // GIS Validation
        if (!gisService.isLocationValid(dto.getLatitude(), dto.getLongitude(), dto.getFacilityType(), 100.0)) { // 100
                                                                                                                // meters
                                                                                                                // minimum
                                                                                                                // distance
                                                                                                                // for
                                                                                                                // example
            throw new RuntimeException("Location validation failed: A similar facility is too close.");
        }

        String code = "FAC-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        Facility facility = Facility.builder()
                .facilityCode(code)
                .nameAr(dto.getNameAr())
                .nameEn(dto.getNameEn())
                .facilityType(dto.getFacilityType())
                .licenseType(dto.getLicenseType())
                .district(dto.getDistrict())
                .area(dto.getArea())
                .street(dto.getStreet())
                .propertyOwner(dto.getPropertyOwner())
                .roomsCount(dto.getRoomsCount())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .isActive(true)
                .build();

        facility = facilityRepository.save(facility);
        return mapToDto(facility);
    }

    @Transactional
    public FacilityDto updateLocation(Long facilityId, Double latitude, Double longitude) {
        Facility facility = facilityRepository.findById(facilityId)
                .orElseThrow(() -> new RuntimeException("Facility not found"));

        if (!gisService.isLocationValid(latitude, longitude, facility.getFacilityType(), 100.0)) {
            throw new RuntimeException("Location validation failed: A similar facility is too close.");
        }

        facility.setLatitude(latitude);
        facility.setLongitude(longitude);
        facilityRepository.save(facility);

        return mapToDto(facility);
    }

    @Transactional(readOnly = true)
    public Page<FacilityDto> getAll(Pageable pageable) {
        return facilityRepository.findAll(pageable).map(this::mapToDto);
    }

    @Transactional(readOnly = true)
    public FacilityDto getById(Long id) {
        Facility f = facilityRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Facility not found"));
        return mapToDto(f);
    }

    private FacilityDto mapToDto(Facility f) {
        return FacilityDto.builder()
                .id(f.getId())
                .facilityCode(f.getFacilityCode())
                .nameAr(f.getNameAr())
                .nameEn(f.getNameEn())
                .facilityType(f.getFacilityType())
                .licenseType(f.getLicenseType())
                .district(f.getDistrict())
                .area(f.getArea())
                .street(f.getStreet())
                .propertyOwner(f.getPropertyOwner())
                .roomsCount(f.getRoomsCount())
                .latitude(f.getLatitude())
                .longitude(f.getLongitude())
                .isActive(f.getIsActive())
                .build();
    }
}
