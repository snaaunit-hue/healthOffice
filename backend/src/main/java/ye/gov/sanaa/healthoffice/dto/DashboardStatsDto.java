package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.util.Map;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DashboardStatsDto {
    private long totalApplications;
    private long pendingReview;
    private long inspectionsScheduled;
    private long activeLicenses;
    private long activeViolations;
    private long expiringLicenses;
    private long totalFacilities;
    private Map<String, Long> applicationsByStatus;
}
