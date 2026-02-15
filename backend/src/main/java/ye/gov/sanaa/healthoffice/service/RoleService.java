package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ye.gov.sanaa.healthoffice.dto.PermissionDto;
import ye.gov.sanaa.healthoffice.dto.RoleDto;
import ye.gov.sanaa.healthoffice.entity.Permission;
import ye.gov.sanaa.healthoffice.entity.Role;
import ye.gov.sanaa.healthoffice.repository.PermissionRepository;
import ye.gov.sanaa.healthoffice.repository.RoleRepository;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class RoleService {

    private final RoleRepository roleRepository;
    private final PermissionRepository permissionRepository;

    @Transactional(readOnly = true)
    public List<RoleDto> getAllRoles() {
        return roleRepository.findAll().stream()
                .map(this::toRoleDto)
                .collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<PermissionDto> getAllPermissions() {
        return permissionRepository.findAll().stream()
                .map(this::toPermissionDto)
                .collect(Collectors.toList());
    }

    private RoleDto toRoleDto(Role r) {
        return RoleDto.builder()
                .id(r.getId())
                .code(r.getCode())
                .nameAr(r.getNameAr())
                .nameEn(r.getNameEn())
                .permissionCodes(r.getPermissions().stream().map(Permission::getCode).collect(Collectors.toSet()))
                .build();
    }

    private PermissionDto toPermissionDto(Permission p) {
        return PermissionDto.builder()
                .id(p.getId())
                .code(p.getCode())
                .descriptionAr(p.getDescriptionAr())
                .descriptionEn(p.getDescriptionEn())
                .build();
    }
}
