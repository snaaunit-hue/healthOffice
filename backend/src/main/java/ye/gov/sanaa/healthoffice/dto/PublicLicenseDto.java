package ye.gov.sanaa.healthoffice.dto;

import lombok.Builder;
import lombok.Data;
import java.time.LocalDate;

@Data
@Builder
public class PublicLicenseDto {
    private String facilityName;
    private String licenseNumber;
    private String facilityType;
    private String status;
    private LocalDate issueDate;
    private LocalDate expiryDate;
    private Boolean isValid;
    private String district;
    private String supervisorName;
}
