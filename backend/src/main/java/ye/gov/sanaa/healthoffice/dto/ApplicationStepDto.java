package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.time.OffsetDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApplicationStepDto {
    private Long id;
    private Integer stepOrder;
    private String stepCode;
    private String status;
    private String performedByName;
    private OffsetDateTime performedAt;
    private String notes;
}
