package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import ye.gov.sanaa.healthoffice.entity.Inspection;
import java.util.List;

public interface InspectionRepository extends JpaRepository<Inspection, Long> {
    List<Inspection> findByApplicationId(Long applicationId);

    Page<Inspection> findByStatus(String status, Pageable pageable);

    Page<Inspection> findByInspectorId(Long inspectorId, Pageable pageable);
}
