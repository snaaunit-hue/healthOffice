package ye.gov.sanaa.healthoffice.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.OffsetDateTime;

@Entity
@Table(name = "medical_professionals")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MedicalProfessional {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "national_id", unique = true, nullable = false, length = 20)
    private String nationalId;

    @Column(name = "full_name_ar", nullable = false)
    private String fullNameAr;

    @Column(name = "full_name_en")
    private String fullNameEn;

    @Column(name = "phone_number", length = 20)
    private String phoneNumber;

    @Column(name = "email", length = 100)
    private String email;

    @Column(name = "qualification", nullable = false)
    private String qualification; // e.g., Bachelor, Master, PhD

    @Column(name = "specialization", nullable = false)
    private String specialization; // e.g., General Practitioner, Pharmacist, Dentist

    @Column(name = "university")
    private String university;

    @Column(name = "graduation_year")
    private Integer graduationYear;

    @Column(name = "practice_license_number", unique = true, nullable = false, length = 50)
    private String practiceLicenseNumber; // Issued by Medical Council

    @Column(name = "license_issue_date")
    private LocalDate licenseIssueDate;

    @Column(name = "license_expiry_date", nullable = false)
    private LocalDate licenseExpiryDate;

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
