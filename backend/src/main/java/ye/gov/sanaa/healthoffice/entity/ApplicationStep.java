package ye.gov.sanaa.healthoffice.entity;

import jakarta.persistence.*;
import lombok.*;
import java.time.OffsetDateTime;

@Entity
@Table(name = "application_steps")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ApplicationStep {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "application_id", nullable = false)
    private Application application;

    @Column(name = "step_order", nullable = false)
    private Integer stepOrder;

    @Column(name = "step_code", nullable = false, length = 50)
    private String stepCode;

    @Column(nullable = false, length = 30)
    private String status; // PENDING, IN_PROGRESS, COMPLETED, REJECTED

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "performed_by_admin")
    private Admin performedByAdmin;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "performed_by_user")
    private FacilityUser performedByUser;

    @Column(name = "performed_at")
    private OffsetDateTime performedAt;

    @Column(columnDefinition = "TEXT")
    private String notes;
}
