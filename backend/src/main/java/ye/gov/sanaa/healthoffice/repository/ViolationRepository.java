package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ye.gov.sanaa.healthoffice.entity.Violation;
import java.util.List;

public interface ViolationRepository extends JpaRepository<Violation, Long> {
    List<Violation> findByInspectionId(Long inspectionId);

    List<Violation> findByApplicationId(Long applicationId);

    List<Violation> findByIsActiveTrue();
}
