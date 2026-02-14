package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PaymentDto {
    private Long id;
    private Long applicationId;
    private String applicationNumber;
    private String paymentReference;
    private String governorateCode;
    private BigDecimal amount;
    private String status;
    private OffsetDateTime paidAt;
    private String paymentChannel;
}
