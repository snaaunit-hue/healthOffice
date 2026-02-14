package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.time.OffsetDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApplicationDto {
    private Long id;
    private String applicationNumber;
    private Long facilityId;
    private String facilityNameAr;
    private String facilityNameEn;
    private String status;
    private String licenseType;
    private String facilityType;

    // Section B – supervisor
    private String supervisorName;
    private String supervisorPhone;
    private String supervisorNationalId;
    private String supervisorIdIssuer;
    private String supervisorIdIssueDate;
    private String supervisorQualification;
    private String supervisorUniversity;
    private String supervisorQualIssuer;
    private String supervisorQualDate;
    private String supervisorPracticeLicense;
    private String supervisorLicenseExpiry;

    // Section C – previous license
    private String prevIssuingAuthority;
    private String prevLicenseNumber;
    private String prevLicenseDate;
    private String prevValidityPeriod;

    private OffsetDateTime createdAt;
    private OffsetDateTime submittedAt;
    private OffsetDateTime approvedAt;
    private String rejectionReason;

    private List<ApplicationStepDto> steps;
    private List<ApplicationDocumentDto> documents;
    private LicenseDto license;
}
