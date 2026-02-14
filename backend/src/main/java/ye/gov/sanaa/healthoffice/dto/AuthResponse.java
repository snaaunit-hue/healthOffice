package ye.gov.sanaa.healthoffice.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuthResponse {
    private String accessToken;
    private String refreshToken;
    private String actorType; // ADMIN, FACILITY_USER
    private Long actorId;
    private String fullName;
    private String role; // role code for admin
    private Long facilityId; // for facility users
    private boolean mustChangePassword;
}
