package ye.gov.sanaa.healthoffice.dto;

import lombok.*;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class RegisterOwnerDto {
    private String firstName;
    private String middleName;
    private String lastName;
    private String nationalId;
    private String phoneNumber;
    private String email;
    private String password;
    private String confirmPassword;
}
