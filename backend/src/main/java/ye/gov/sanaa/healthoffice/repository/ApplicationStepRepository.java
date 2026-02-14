package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ye.gov.sanaa.healthoffice.entity.ApplicationStep;
import java.util.List;

public interface ApplicationStepRepository extends JpaRepository<ApplicationStep, Long> {
    List<ApplicationStep> findByApplicationIdOrderByStepOrderAsc(Long applicationId);
}
