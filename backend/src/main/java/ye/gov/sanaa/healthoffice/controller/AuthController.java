package ye.gov.sanaa.healthoffice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ye.gov.sanaa.healthoffice.dto.AuthResponse;
import ye.gov.sanaa.healthoffice.dto.LoginRequest;
import ye.gov.sanaa.healthoffice.dto.RegisterOwnerDto;
import ye.gov.sanaa.healthoffice.service.AuthService;

@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;

    @PostMapping("/admin/login")
    public ResponseEntity<AuthResponse> adminLogin(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.loginAdmin(request));
    }

    @PostMapping("/user/login")
    public ResponseEntity<AuthResponse> userLogin(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.loginFacilityUser(request));
    }

    @PostMapping("/user/register-owner")
    public ResponseEntity<Void> registerOwner(@RequestBody RegisterOwnerDto request) {
        authService.registerOwner(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/refresh")
    public ResponseEntity<AuthResponse> refresh(@RequestBody java.util.Map<String, String> body) {
        String refreshToken = body.get("refreshToken");
        return ResponseEntity.ok(authService.refreshToken(refreshToken));
    }

    @PostMapping("/change-password")
    public ResponseEntity<Void> changePassword(@RequestBody java.util.Map<String, String> body) {
        String actorType = body.get("actorType");
        Long actorId = Long.parseLong(body.get("actorId"));
        String newPassword = body.get("newPassword");
        authService.changePassword(actorType, actorId, newPassword);
        return ResponseEntity.ok().build();
    }
}
