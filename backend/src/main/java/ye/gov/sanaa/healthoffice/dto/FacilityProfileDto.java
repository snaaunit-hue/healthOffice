package ye.gov.sanaa.healthoffice.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FacilityProfileDto {
    private FacilityDto facility;
    private String currentLicenseNumber;
    private String currentLicenseStatus;
    private java.time.LocalDate licenseExpiryDate;
    private int inspectionsCount;
    private long applicationsCount;
}
