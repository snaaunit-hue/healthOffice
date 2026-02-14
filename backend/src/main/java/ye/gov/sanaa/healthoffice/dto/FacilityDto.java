package ye.gov.sanaa.healthoffice.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class FacilityDto {
    private Long id;
    private String facilityCode;
    private String nameAr;
    private String nameEn;
    private String facilityType;
    private String licenseType;
    private String district;
    private String area;
    private String street;
    private String propertyOwner;
    private Integer roomsCount;
    private Double latitude;
    private Double longitude;
    private Boolean isActive;
}
