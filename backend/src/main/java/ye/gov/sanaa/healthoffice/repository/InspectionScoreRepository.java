package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ye.gov.sanaa.healthoffice.entity.InspectionScore;
import java.util.List;

public interface InspectionScoreRepository extends JpaRepository<InspectionScore, Long> {
    List<InspectionScore> findByInspectionId(Long inspectionId);
}
