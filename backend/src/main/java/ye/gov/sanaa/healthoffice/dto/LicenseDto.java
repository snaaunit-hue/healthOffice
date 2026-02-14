package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LicenseDto {
    private Long id;
    private Long applicationId;
    private String applicationNumber;
    private String facilityNameAr;
    private String licenseNumber;
    private LocalDate issueDate;
    private LocalDate expiryDate;
    private String pdfUrl;
    private String status;
}
