package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ye.gov.sanaa.healthoffice.entity.SystemSetting;
import java.util.Optional;
import java.util.List;

public interface SystemSettingRepository extends JpaRepository<SystemSetting, Long> {
    Optional<SystemSetting> findByCategoryAndSettingKey(String category, String settingKey);

    List<SystemSetting> findByCategory(String category);
}
