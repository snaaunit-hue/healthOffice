package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ye.gov.sanaa.healthoffice.entity.AuditLog;
import ye.gov.sanaa.healthoffice.repository.AuditLogRepository;
import ye.gov.sanaa.healthoffice.repository.AdminRepository;
import ye.gov.sanaa.healthoffice.repository.FacilityUserRepository;

@Service
@RequiredArgsConstructor
public class AuditService {

    private final AuditLogRepository auditLogRepository;
    private final AdminRepository adminRepository;
    private final FacilityUserRepository facilityUserRepository;

    public void log(Long adminId, Long userId, String action, String entityType, Long entityId, String details) {
        AuditLog log = AuditLog.builder()
                .action(action)
                .entityType(entityType)
                .entityId(entityId)
                .details(details)
                .build();
        if (adminId != null) {
            log.setActorAdmin(adminRepository.findById(adminId).orElse(null));
        }
        if (userId != null) {
            log.setActorUser(facilityUserRepository.findById(userId).orElse(null));
        }
        auditLogRepository.save(log);
    }
}
