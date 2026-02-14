package ye.gov.sanaa.healthoffice.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.OffsetDateTime;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class FacilityUserDto {
    private Long id;
    private String firstName;
    private String middleName;
    private String lastName;
    private String nationalId;
    private String phoneNumber;
    private String email;
    private boolean enabled;
    private Long facilityId;
    private String facilityName;
    private OffsetDateTime createdAt;
}
