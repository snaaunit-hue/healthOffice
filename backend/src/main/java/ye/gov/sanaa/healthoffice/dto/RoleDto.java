package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.util.Set;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RoleDto {
    private Long id;
    private String code;
    private String nameAr;
    private String nameEn;
    private Set<String> permissionCodes;
}
