package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.time.OffsetDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ViolationDto {
    private Long id;
    private Long applicationId;
    private String facilityNameAr;
    private String code;
    private String description;
    private String penalty;
    private String severity;
    private Boolean isActive;
    private OffsetDateTime createdAt;
}
