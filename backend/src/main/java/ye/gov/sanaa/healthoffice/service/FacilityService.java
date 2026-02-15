package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ye.gov.sanaa.healthoffice.dto.FacilityDto;
import ye.gov.sanaa.healthoffice.dto.FacilityProfileDto;
import ye.gov.sanaa.healthoffice.entity.Application;
import ye.gov.sanaa.healthoffice.entity.Facility;
import ye.gov.sanaa.healthoffice.entity.License;
import ye.gov.sanaa.healthoffice.repository.FacilityRepository;
import ye.gov.sanaa.healthoffice.repository.FacilityUserRepository;
import ye.gov.sanaa.healthoffice.repository.InspectionRepository;
import ye.gov.sanaa.healthoffice.repository.LicenseRepository;
import ye.gov.sanaa.healthoffice.repository.ApplicationRepository;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FacilityService {

    private final FacilityRepository facilityRepository;
    private final FacilityUserRepository facilityUserRepository;
    private final LicenseRepository licenseRepository;
    private final InspectionRepository inspectionRepository;
    private final ApplicationRepository applicationRepository;
    private final GISService gisService;
    private final AuditService auditService;

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
                .governorate(dto.getGovernorate())
                .sector(dto.getSector() != null ? dto.getSector() : "خاص")
                .specialty(dto.getSpecialty())
                .operationalStatus(dto.getOperationalStatus() != null ? dto.getOperationalStatus() : "ACTIVE")
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
                .governorate(f.getGovernorate())
                .sector(f.getSector())
                .specialty(f.getSpecialty())
                .operationalStatus(f.getOperationalStatus())
                .build();
    }

    @Transactional
    public FacilityDto updateOperationalStatus(Long facilityId, String operationalStatus, Long adminId) {
        if (!List.of("ACTIVE", "CLOSED", "SUSPENDED", "UNDER_REVIEW").contains(operationalStatus)) {
            throw new IllegalArgumentException("Invalid operational status: " + operationalStatus);
        }
        Facility facility = facilityRepository.findById(facilityId)
                .orElseThrow(() -> new RuntimeException("Facility not found"));
        String previous = facility.getOperationalStatus();
        facility.setOperationalStatus(operationalStatus);
        facility.setIsActive("ACTIVE".equals(operationalStatus));
        facility = facilityRepository.save(facility);
        auditService.log(adminId, null, "FACILITY_OPERATIONAL_STATUS", "FACILITY", facilityId,
                "Changed from " + previous + " to " + operationalStatus);
        return mapToDto(facility);
    }

    @Transactional(readOnly = true)
    public FacilityProfileDto getProfile(Long facilityId) {
        Facility facility = facilityRepository.findById(facilityId)
                .orElseThrow(() -> new RuntimeException("Facility not found"));
        FacilityDto dto = mapToDto(facility);
        List<License> licenses = licenseRepository.findByApplication_Facility_IdOrderByIssueDateDesc(
                facilityId, PageRequest.of(0, 1));
        License currentLicense = licenses.isEmpty() ? null : licenses.get(0);
        List<Application> apps = applicationRepository.findByFacilityId(facilityId);
        int inspectionsCount = apps.stream()
                .mapToInt(app -> inspectionRepository.findByApplicationId(app.getId()).size())
                .sum();
        long applicationsCount = apps.size();
        return FacilityProfileDto.builder()
                .facility(dto)
                .currentLicenseNumber(currentLicense != null ? currentLicense.getLicenseNumber() : null)
                .currentLicenseStatus(currentLicense != null ? currentLicense.getStatus() : null)
                .licenseExpiryDate(currentLicense != null ? currentLicense.getExpiryDate() : null)
                .inspectionsCount((int) inspectionsCount)
                .applicationsCount(applicationsCount)
                .build();
    }

    @Transactional(readOnly = true)
    public List<FacilityDto> getFacilitiesForUser(Long facilityUserId) {
        return facilityUserRepository.findById(facilityUserId)
                .map(u -> {
                    if (u.getFacility() != null) {
                        return List.of(mapToDto(u.getFacility()));
                    }
                    return List.<FacilityDto>of();
                })
                .orElse(List.of());
    }

    @Transactional(readOnly = true)
    public List<FacilityDto> getFacilitiesForUserByPhone(String phoneNumber) {
        return facilityUserRepository.findAllByPhoneNumber(phoneNumber).stream()
                .filter(u -> u.getFacility() != null)
                .map(u -> mapToDto(u.getFacility()))
                .distinct()
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<FacilityDto> getAllFiltered(String facilityType, String governorate, String district,
                                            String operationalStatus, Pageable pageable) {
        if (facilityType != null && !facilityType.isBlank() && operationalStatus != null && !operationalStatus.isBlank()) {
            return facilityRepository.findByFacilityTypeAndOperationalStatus(facilityType, operationalStatus, pageable)
                    .map(this::mapToDto);
        }
        if (operationalStatus != null && !operationalStatus.isBlank()) {
            return facilityRepository.findByOperationalStatus(operationalStatus, pageable).map(this::mapToDto);
        }
        if (governorate != null && !governorate.isBlank()) {
            return facilityRepository.findByGovernorate(governorate, pageable).map(this::mapToDto);
        }
        if (district != null && !district.isBlank()) {
            return facilityRepository.findByDistrict(district, pageable).map(this::mapToDto);
        }
        return facilityRepository.findAll(pageable).map(this::mapToDto);
    }
}
