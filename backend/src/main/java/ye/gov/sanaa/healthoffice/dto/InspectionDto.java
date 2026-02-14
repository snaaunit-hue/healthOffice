package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InspectionDto {
    private Long id;
    private Long applicationId;
    private String applicationNumber;
    private OffsetDateTime scheduledDate;
    private OffsetDateTime actualVisitDate;
    private Long inspectorId;
    private String inspectorName;
    private String status;
    private BigDecimal overallScore;
    private String notes;
    private java.util.List<InspectionScoreDto> items;
}
