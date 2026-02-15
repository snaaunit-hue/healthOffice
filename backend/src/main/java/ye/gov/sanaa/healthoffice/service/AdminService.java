package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ye.gov.sanaa.healthoffice.dto.AdminDto;
import ye.gov.sanaa.healthoffice.dto.CreateEmployeeDto;
import ye.gov.sanaa.healthoffice.dto.UpdateEmployeeDto;
import ye.gov.sanaa.healthoffice.entity.Admin;
import ye.gov.sanaa.healthoffice.entity.Role;
import ye.gov.sanaa.healthoffice.dto.FacilityUserDto;
import ye.gov.sanaa.healthoffice.entity.FacilityUser;
import ye.gov.sanaa.healthoffice.repository.AdminRepository;
import ye.gov.sanaa.healthoffice.repository.FacilityUserRepository;
import ye.gov.sanaa.healthoffice.repository.RoleRepository;

import java.util.HashSet;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AdminService {

    private final AdminRepository adminRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final FacilityUserRepository facilityUserRepository;

    @Transactional
    public AdminDto createEmployee(CreateEmployeeDto dto) {
        if (adminRepository.existsByUsername(dto.getUsername())) {
            throw new RuntimeException("Username already exists");
        }

        Admin admin = new Admin();
        admin.setFullName(dto.getFullName());
        admin.setUsername(dto.getUsername());
        admin.setPasswordHash(passwordEncoder.encode(dto.getPassword()));
        admin.setPhoneNumber(dto.getPhoneNumber());
        admin.setEmail(dto.getEmail());
        admin.setEnabled(true);

        Set<Role> roles = new HashSet<>();
        if (dto.getRoles() != null) {
            for (String roleCode : dto.getRoles()) {
                roleRepository.findByCode(roleCode).ifPresent(roles::add);
            }
        }
        if (roles.isEmpty()) {
            Role defaultRole = roleRepository.findByCode("LICENSING_OFFICER")
                    .or(() -> roleRepository.findByCode("SYSTEM_ADMIN"))
                    .or(() -> roleRepository.findAll().stream().findFirst())
                    .orElseThrow(() -> new RuntimeException("No roles found in system. Please run seed data."));
            roles.add(defaultRole);
        }
        admin.setRoles(roles);

        return toDto(adminRepository.save(admin));
    }

    @Transactional
    public AdminDto updateEmployee(Long id, UpdateEmployeeDto dto) {
        Admin admin = adminRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Employee not found"));

        if (dto.getFullName() != null)
            admin.setFullName(dto.getFullName());
        if (dto.getPhoneNumber() != null)
            admin.setPhoneNumber(dto.getPhoneNumber());
        if (dto.getEmail() != null)
            admin.setEmail(dto.getEmail());
        if (dto.getEnabled() != null)
            admin.setEnabled(dto.getEnabled());

        if (dto.getRoles() != null && !dto.getRoles().isEmpty()) {
            Set<Role> roles = new HashSet<>();
            for (String roleCode : dto.getRoles()) {
                roleRepository.findByCode(roleCode).ifPresent(roles::add);
            }
            admin.setRoles(roles);
        }

        return toDto(adminRepository.save(admin));
    }

    @Transactional
    public void deleteEmployee(Long id) {
        if (!adminRepository.existsById(id)) {
            throw new RuntimeException("Employee not found");
        }
        adminRepository.deleteById(id);
    }

    @Transactional(readOnly = true)
    public Page<AdminDto> getAllEmployees(Pageable pageable) {
        return adminRepository.findAll(pageable).map(this::toDto);
    }

    @Transactional(readOnly = true)
    public AdminDto getEmployee(Long id) {
        return adminRepository.findById(id)
                .map(this::toDto)
                .orElseThrow(() -> new RuntimeException("Employee not found"));
    }

    public AdminDto toDto(Admin admin) {
        return AdminDto.builder()
                .id(admin.getId())
                .username(admin.getUsername())
                .fullName(admin.getFullName())
                .email(admin.getEmail())
                .phoneNumber(admin.getPhoneNumber())
                .enabled(admin.isEnabled())
                .roles(admin.getRoles().stream().map(Role::getCode).collect(Collectors.toSet()))
                .build();
    }

    // ===== Facility User Management =====

    @Transactional(readOnly = true)
    public Page<FacilityUserDto> getAllFacilityUsers(Pageable pageable) {
        return facilityUserRepository.findAll(pageable).map(this::toFacilityUserDto);
    }

    @Transactional
    public FacilityUserDto toggleUserStatus(Long id) {
        FacilityUser user = facilityUserRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("User not found"));
        user.setIsActive(!user.getIsActive());
        return toFacilityUserDto(facilityUserRepository.save(user));
    }

    private FacilityUserDto toFacilityUserDto(FacilityUser user) {
        return FacilityUserDto.builder()
                .id(user.getId())
                .firstName(user.getFirstName())
                .middleName(user.getMiddleName())
                .lastName(user.getLastName())
                .nationalId(user.getNationalId())
                .phoneNumber(user.getPhoneNumber())
                .email(user.getEmail())
                .enabled(user.getIsActive())
                .facilityId(user.getFacility() != null ? user.getFacility().getId() : null)
                .facilityName(user.getFacility() != null ? user.getFacility().getNameAr() : "N/A")
                .createdAt(user.getCreatedAt())
                .build();
    }
}
