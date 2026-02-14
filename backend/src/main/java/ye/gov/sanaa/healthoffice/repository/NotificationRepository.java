package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import ye.gov.sanaa.healthoffice.entity.Notification;

public interface NotificationRepository extends JpaRepository<Notification, Long> {
    Page<Notification> findByRecipientUserIdOrderByCreatedAtDesc(Long userId, Pageable pageable);

    Page<Notification> findByRecipientAdminIdOrderByCreatedAtDesc(Long adminId, Pageable pageable);

    long countByRecipientUserIdAndReadFalse(Long userId);

    long countByRecipientAdminIdAndReadFalse(Long adminId);
}
