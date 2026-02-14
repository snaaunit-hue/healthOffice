package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ye.gov.sanaa.healthoffice.dto.DashboardStatsDto;
import ye.gov.sanaa.healthoffice.repository.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class DashboardService {

    private final ApplicationRepository applicationRepository;
    private final FacilityRepository facilityRepository;
    private final LicenseRepository licenseRepository;
    private final ViolationRepository violationRepository;

    public DashboardStatsDto getStats() {
        Map<String, Long> statusCounts = new HashMap<>();
        List<String> statuses = List.of(
                "DRAFT", "SUBMITTED", "UNDER_REVIEW", "INSPECTION_SCHEDULED",
                "INSPECTION_COMPLETED", "COMMITTEE_APPROVED", "PAYMENT_PENDING",
                "PAYMENT_COMPLETED", "LICENSE_ISSUED", "REJECTED", "ARCHIVED");
        for (String s : statuses) {
            statusCounts.put(s, applicationRepository.countByStatus(s));
        }

        return DashboardStatsDto.builder()
                .totalApplications(applicationRepository.count())
                .pendingReview(applicationRepository.countByStatus("SUBMITTED") +
                        applicationRepository.countByStatus("UNDER_REVIEW"))
                .inspectionsScheduled(applicationRepository.countByStatus("INSPECTION_SCHEDULED"))
                .activeLicenses(licenseRepository.count())
                .expiringLicenses(licenseRepository.countByExpiryDateBefore(java.time.LocalDate.now().plusDays(30)))
                .totalFacilities(facilityRepository.count())
                .activeViolations(violationRepository.findByIsActiveTrue().size())
                .applicationsByStatus(statusCounts)
                .build();
    }
}
