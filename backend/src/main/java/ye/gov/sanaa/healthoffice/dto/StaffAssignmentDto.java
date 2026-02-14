package ye.gov.sanaa.healthoffice.dto;

import lombok.Data;
import java.time.LocalDate;

@Data
public class StaffAssignmentDto {
    private Long medicalProfessionalId;
    private Long facilityId;
    private String jobTitle;
    private Boolean isTechnicalManager;
    private String contractType;
    private LocalDate contractStartDate;
    private LocalDate contractEndDate;
}
