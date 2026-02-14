package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import ye.gov.sanaa.healthoffice.dto.AuthResponse;
import ye.gov.sanaa.healthoffice.dto.LoginRequest;
import ye.gov.sanaa.healthoffice.dto.RegisterOwnerDto;
import ye.gov.sanaa.healthoffice.entity.Admin;
import ye.gov.sanaa.healthoffice.entity.FacilityUser;
import ye.gov.sanaa.healthoffice.repository.AdminRepository;
import ye.gov.sanaa.healthoffice.repository.FacilityUserRepository;
import ye.gov.sanaa.healthoffice.security.JwtTokenProvider;

import java.time.OffsetDateTime;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final AdminRepository adminRepository;
    private final FacilityUserRepository facilityUserRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;
    private final AuditService auditService;

    public AuthResponse loginAdmin(LoginRequest request) {
        Admin admin = adminRepository.findByUsername(request.getUsername())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!admin.isEnabled()) {
            throw new RuntimeException("Account is deactivated");
        }
        if (!passwordEncoder.matches(request.getPassword(), admin.getPasswordHash())) {
            throw new RuntimeException("Invalid credentials");
        }

        admin.setLastLoginAt(OffsetDateTime.now());
        adminRepository.save(admin);

        String roleCode = admin.getRoles().isEmpty() ? "" : admin.getRoles().iterator().next().getCode();
        Map<String, Object> claims = Map.of(
                "actorType", "ADMIN",
                "actorId", admin.getId(),
                "role", roleCode);

        String accessToken = jwtTokenProvider.createAccessToken(admin.getUsername(), claims);
        String refreshToken = jwtTokenProvider.createRefreshToken(admin.getUsername());

        auditService.log(admin.getId(), null, "LOGIN", "ADMIN", admin.getId(), "Admin login");

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .actorType("ADMIN")
                .actorId(admin.getId())
                .fullName(admin.getFullName())
                .role(roleCode)
                .build();
    }

    public AuthResponse loginFacilityUser(LoginRequest request) {
        FacilityUser user = facilityUserRepository.findByPhoneNumber(request.getPhoneNumber())
                .orElseThrow(() -> new RuntimeException("Invalid credentials"));

        if (!user.getIsActive()) {
            throw new RuntimeException("Account is deactivated");
        }

        boolean usedDefaultOtp = "1234".equals(request.getPassword());
        boolean passwordMatches = passwordEncoder.matches(request.getPassword(), user.getPasswordHash())
                || usedDefaultOtp;

        if (!passwordMatches) {
            throw new RuntimeException("Invalid credentials");
        }

        user.setLastLoginAt(OffsetDateTime.now());
        facilityUserRepository.save(user);

        Long facilityId = user.getFacility() != null ? user.getFacility().getId() : null;

        Map<String, Object> claims = new java.util.HashMap<>();
        claims.put("actorType", "FACILITY_USER");
        claims.put("actorId", user.getId());
        claims.put("facilityId", facilityId);
        claims.put("role", user.getUserType());

        String accessToken = jwtTokenProvider.createAccessToken(user.getPhoneNumber(), claims);
        String refreshToken = jwtTokenProvider.createRefreshToken(user.getPhoneNumber());

        auditService.log(null, user.getId(), "LOGIN", "FACILITY_USER", user.getId(), "Facility user login");

        return AuthResponse.builder()
                .accessToken(accessToken)
                .refreshToken(refreshToken)
                .actorType("FACILITY_USER")
                .actorId(user.getId())
                .fullName(user.getFullName())
                .role(user.getUserType())
                .facilityId(user.getFacility() != null ? user.getFacility().getId() : null)
                .mustChangePassword(usedDefaultOtp)
                .build();
    }

    public AuthResponse refreshToken(String refreshToken) {
        if (!jwtTokenProvider.validateToken(refreshToken)) {
            throw new RuntimeException("Invalid refresh token");
        }
        String subject = jwtTokenProvider.getSubject(refreshToken);

        // Try admin first
        var adminOpt = adminRepository.findByUsername(subject);
        if (adminOpt.isPresent()) {
            Admin admin = adminOpt.get();
            String roleCode = admin.getRoles().isEmpty() ? "" : admin.getRoles().iterator().next().getCode();
            Map<String, Object> claims = Map.of(
                    "actorType", "ADMIN", "actorId", admin.getId(), "role", roleCode);
            String newAccess = jwtTokenProvider.createAccessToken(subject, claims);
            String newRefresh = jwtTokenProvider.createRefreshToken(subject);
            return AuthResponse.builder()
                    .accessToken(newAccess).refreshToken(newRefresh)
                    .actorType("ADMIN").actorId(admin.getId())
                    .fullName(admin.getFullName()).role(roleCode).build();
        }

        // Try facility user
        var userOpt = facilityUserRepository.findByPhoneNumber(subject);
        if (userOpt.isPresent()) {
            FacilityUser user = userOpt.get();
            Long facilityId = user.getFacility() != null ? user.getFacility().getId() : null;

            Map<String, Object> claims = new java.util.HashMap<>();
            claims.put("actorType", "FACILITY_USER");
            claims.put("actorId", user.getId());
            claims.put("facilityId", facilityId);
            claims.put("role", user.getUserType());

            String newAccess = jwtTokenProvider.createAccessToken(subject, claims);
            String newRefresh = jwtTokenProvider.createRefreshToken(subject);
            return AuthResponse.builder()
                    .accessToken(newAccess).refreshToken(newRefresh)
                    .actorType("FACILITY_USER").actorId(user.getId())
                    .fullName(user.getFullName()).role(user.getUserType())
                    .facilityId(facilityId).build();
        }

        throw new RuntimeException("Token subject not found");
    }

    @org.springframework.transaction.annotation.Transactional
    public void registerOwner(RegisterOwnerDto dto) {
        if (!dto.getPassword().equals(dto.getConfirmPassword())) {
            throw new RuntimeException("Passwords do not match");
        }
        if (facilityUserRepository.existsByPhoneNumber(dto.getPhoneNumber())) {
            throw new RuntimeException("Phone number already registered");
        }

        FacilityUser user = FacilityUser.builder()
                .firstName(dto.getFirstName())
                .middleName(dto.getMiddleName())
                .lastName(dto.getLastName())
                .phoneNumber(dto.getPhoneNumber())
                .email(dto.getEmail())
                .nationalId(dto.getNationalId())
                .passwordHash(passwordEncoder.encode(dto.getPassword()))
                .userType("OWNER")
                .isActive(true)
                .build();

        facilityUserRepository.save(user);
        auditService.log(null, user.getId(), "REGISTER", "FACILITY_USER", user.getId(),
                "Owner registered: " + user.getPhoneNumber());
    }

    @org.springframework.transaction.annotation.Transactional
    public void changePassword(String actorType, Long actorId, String newPassword) {
        String encoded = passwordEncoder.encode(newPassword);
        if ("ADMIN".equals(actorType)) {
            adminRepository.findById(actorId).ifPresent(admin -> {
                admin.setPasswordHash(encoded);
                adminRepository.save(admin);
            });
        } else {
            facilityUserRepository.findById(actorId).ifPresent(user -> {
                user.setPasswordHash(encoded);
                facilityUserRepository.save(user);
            });
        }
    }
}
