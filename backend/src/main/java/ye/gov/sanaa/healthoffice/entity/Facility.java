package ye.gov.sanaa.healthoffice.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;

@Entity
@Table(name = "facilities")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Facility {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "facility_code", unique = true, nullable = false, length = 50)
    private String facilityCode;

    @Column(name = "name_ar", nullable = false)
    private String nameAr;

    @Column(name = "name_en")
    private String nameEn;

    @Column(name = "facility_type", nullable = false, length = 50)
    private String facilityType;

    @Column(name = "license_type", nullable = false, length = 20)
    private String licenseType;

    @Column(length = 150)
    private String district;

    @Column(length = 150)
    private String area;

    @Column(length = 150)
    private String street;

    @Column(name = "latitude")
    private Double latitude;

    @Column(name = "longitude")
    private Double longitude;

    @Column(name = "property_owner")
    private String propertyOwner;

    @Column(name = "ownership_proof_url", columnDefinition = "TEXT")
    private String ownershipProofUrl;

    @Column(name = "site_sketch_url", columnDefinition = "TEXT")
    private String siteSketchUrl;

    @Column(name = "rooms_count")
    private Integer roomsCount;

    @Column(name = "is_active", nullable = false)
    @Builder.Default
    private Boolean isActive = true;

    @Column(length = 100)
    private String governorate;

    @Column(length = 50)
    private String sector;

    @Column(length = 255)
    private String specialty;

    @Column(name = "operational_status", length = 30, nullable = false)
    @Builder.Default
    private String operationalStatus = "ACTIVE"; // ACTIVE, CLOSED, SUSPENDED, UNDER_REVIEW

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at", nullable = false)
    private OffsetDateTime updatedAt;

    @PrePersist
    void prePersist() {
        createdAt = updatedAt = OffsetDateTime.now();
    }

    @PreUpdate
    void preUpdate() {
        updatedAt = OffsetDateTime.now();
    }
}
