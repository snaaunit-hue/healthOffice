package ye.gov.sanaa.healthoffice.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class InspectionScoreDto {
    private Long id;
    private String criterionCode;
    private String description;
    private BigDecimal score;
    private BigDecimal maxScore;
}
