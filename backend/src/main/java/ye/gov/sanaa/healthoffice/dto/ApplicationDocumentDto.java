package ye.gov.sanaa.healthoffice.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApplicationDocumentDto {
    private Long id;
    private String documentType;
    private String referenceNumber;
    private String issueDate;
    private Boolean isMandatory;
    private String fileUrl;
}
