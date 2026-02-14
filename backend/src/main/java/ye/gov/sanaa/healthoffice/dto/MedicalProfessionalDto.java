package ye.gov.sanaa.healthoffice.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class MedicalProfessionalDto {
    private Long id;
    private String nationalId;
    private String fullNameAr;
    private String fullNameEn;
    private String phoneNumber;
    private String email;
    private String qualification;
    private String specialization;
    private String university;
    private Integer graduationYear;
    private String practiceLicenseNumber;
    private LocalDate licenseIssueDate;
    private LocalDate licenseExpiryDate;
}
