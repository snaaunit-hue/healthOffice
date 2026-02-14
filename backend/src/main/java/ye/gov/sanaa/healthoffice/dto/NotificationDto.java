package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.time.OffsetDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class NotificationDto {
    private Long id;
    private String titleAr;
    private String titleEn;
    private String bodyAr;
    private String bodyEn;
    private String type;
    private Boolean read;
    private OffsetDateTime createdAt;
}
