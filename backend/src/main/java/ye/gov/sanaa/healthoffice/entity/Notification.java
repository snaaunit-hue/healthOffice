package ye.gov.sanaa.healthoffice.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;

@Entity
@Table(name = "notifications")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Notification {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipient_admin_id")
    private Admin recipientAdmin;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "recipient_user_id")
    private FacilityUser recipientUser;

    @Column(name = "title_ar")
    private String titleAr;

    @Column(name = "title_en")
    private String titleEn;

    @Column(name = "body_ar", columnDefinition = "TEXT")
    private String bodyAr;

    @Column(name = "body_en", columnDefinition = "TEXT")
    private String bodyEn;

    @Column(length = 50)
    private String type;

    @Column(nullable = false)
    @Builder.Default
    private Boolean read = false;

    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "read_at")
    private OffsetDateTime readAt;

    @PrePersist
    void prePersist() {
        if (createdAt == null)
            createdAt = OffsetDateTime.now();
    }
}
