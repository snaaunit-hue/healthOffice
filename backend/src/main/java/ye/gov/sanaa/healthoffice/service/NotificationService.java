package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import ye.gov.sanaa.healthoffice.dto.NotificationDto;
import ye.gov.sanaa.healthoffice.entity.*;
import ye.gov.sanaa.healthoffice.repository.*;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final AdminRepository adminRepository;
    private final FacilityUserRepository facilityUserRepository;

    public void notifyUser(Long userId, String titleAr, String titleEn, String bodyAr, String bodyEn, String type) {
        Notification n = Notification.builder()
                .recipientUser(facilityUserRepository.findById(userId).orElse(null))
                .titleAr(titleAr).titleEn(titleEn)
                .bodyAr(bodyAr).bodyEn(bodyEn)
                .type(type)
                .build();
        notificationRepository.save(n);
    }

    public void notifyAdmin(Long adminId, String titleAr, String titleEn, String bodyAr, String bodyEn, String type) {
        Notification n = Notification.builder()
                .recipientAdmin(adminRepository.findById(adminId).orElse(null))
                .titleAr(titleAr).titleEn(titleEn)
                .bodyAr(bodyAr).bodyEn(bodyEn)
                .type(type)
                .build();
        notificationRepository.save(n);
    }

    public Page<NotificationDto> getUserNotifications(Long userId, Pageable pageable) {
        return notificationRepository.findByRecipientUserIdOrderByCreatedAtDesc(userId, pageable).map(this::toDto);
    }

    public Page<NotificationDto> getAdminNotifications(Long adminId, Pageable pageable) {
        return notificationRepository.findByRecipientAdminIdOrderByCreatedAtDesc(adminId, pageable).map(this::toDto);
    }

    public long getUnreadCount(Long userId, boolean isAdmin) {
        if (isAdmin)
            return notificationRepository.countByRecipientAdminIdAndReadFalse(userId);
        return notificationRepository.countByRecipientUserIdAndReadFalse(userId);
    }

    public void markAsRead(Long notificationId) {
        notificationRepository.findById(notificationId).ifPresent(n -> {
            n.setRead(true);
            n.setReadAt(java.time.OffsetDateTime.now());
            notificationRepository.save(n);
        });
    }

    private NotificationDto toDto(Notification n) {
        return NotificationDto.builder()
                .id(n.getId())
                .titleAr(n.getTitleAr()).titleEn(n.getTitleEn())
                .bodyAr(n.getBodyAr()).bodyEn(n.getBodyEn())
                .type(n.getType())
                .read(n.getRead())
                .createdAt(n.getCreatedAt())
                .build();
    }
}
