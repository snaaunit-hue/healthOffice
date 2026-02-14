package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateEmployeeDto {
    private String fullName;
    private String phoneNumber;
    private String email;
    private Set<String> roles;
    private Boolean enabled;
}
