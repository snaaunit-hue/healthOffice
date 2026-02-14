package ye.gov.sanaa.healthoffice.dto;

import lombok.*;
import java.util.Set;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateEmployeeDto {
    private String fullName;
    private String username;
    private String password;
    private String phoneNumber;
    private String email;
    private Set<String> roles; // Set of role codes like "ADMIN", "INSPECTOR"
}
