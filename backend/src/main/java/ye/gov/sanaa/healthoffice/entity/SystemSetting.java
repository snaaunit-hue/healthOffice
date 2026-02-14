package ye.gov.sanaa.healthoffice.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "system_settings", uniqueConstraints = @UniqueConstraint(columnNames = { "category", "setting_key" }))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SystemSetting {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 100)
    private String category;

    @Column(name = "setting_key", nullable = false, length = 100)
    private String settingKey;

    @Column(name = "setting_value", nullable = false)
    private String settingValue;

    @Column(columnDefinition = "TEXT")
    private String description;
}
