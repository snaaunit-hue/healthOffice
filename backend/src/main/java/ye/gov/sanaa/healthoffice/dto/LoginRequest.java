package ye.gov.sanaa.healthoffice.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class LoginRequest {
    private String username; // admin username
    private String phoneNumber; // facility user phone
    private String password;
    private String actorType; // ADMIN or FACILITY_USER
}
