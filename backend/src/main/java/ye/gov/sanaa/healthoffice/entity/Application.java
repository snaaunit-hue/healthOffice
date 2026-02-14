package ye.gov.sanaa.healthoffice.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;

@Entity
@Table(name = "applications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Application {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "application_number", unique = true, nullable = false, length = 50)
    private String applicationNumber;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "facility_id", nullable = false)
    private Facility facility;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "submitted_by_user_id")
    private FacilityUser submittedByUser;

    @Column(nullable = false, length = 30)
    private String status; // DRAFT, SUBMITTED, UNDER_REVIEW, INSPECTION_SCHEDULED, INSPECTION_COMPLETED,
                           // COMMITTEE_APPROVED, PAYMENT_PENDING, PAYMENT_COMPLETED, LICENSE_ISSUED,
                           // REJECTED, ARCHIVED

    @Column(name = "license_type", nullable = false, length = 20)
    private String licenseType; // NEW, RENEWAL

    @Column(name = "facility_type", nullable = false, length = 50)
    private String facilityType;

    // Section B – Technical Supervisor
    @Column(name = "supervisor_name")
    private String supervisorName;

    @Column(name = "supervisor_phone", length = 20)
    private String supervisorPhone;

    @Column(name = "supervisor_national_id", length = 50)
    private String supervisorNationalId;

    @Column(name = "supervisor_id_issuer")
    private String supervisorIdIssuer;

    @Column(name = "supervisor_id_issue_date")
    private java.time.LocalDate supervisorIdIssueDate;

    @Column(name = "supervisor_qualification")
    private String supervisorQualification;

    @Column(name = "supervisor_university")
    private String supervisorUniversity;

    @Column(name = "supervisor_qual_issuer")
    private String supervisorQualIssuer;

    @Column(name = "supervisor_qual_date")
    private java.time.LocalDate supervisorQualDate;

    @Column(name = "supervisor_practice_license", length = 100)
    private String supervisorPracticeLicense;

    @Column(name = "supervisor_license_expiry")
    private java.time.LocalDate supervisorLicenseExpiry;

    // Section C – Previous License (renewal)
    @Column(name = "prev_issuing_authority")
    private String prevIssuingAuthority;

    @Column(name = "prev_license_number", length = 100)
    private String prevLicenseNumber;

    @Column(name = "prev_license_date")
    private java.time.LocalDate prevLicenseDate;

    @Column(name = "prev_validity_period")
    private String prevValidityPeriod;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @Column(name = "submitted_at")
    private OffsetDateTime submittedAt;

    @Column(name = "approved_at")
    private OffsetDateTime approvedAt;

    @Column(name = "rejected_at")
    private OffsetDateTime rejectedAt;

    @Column(name = "rejection_reason", columnDefinition = "TEXT")
    private String rejectionReason;

    @PrePersist
    void prePersist() {
        createdAt = updatedAt = OffsetDateTime.now();
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}
