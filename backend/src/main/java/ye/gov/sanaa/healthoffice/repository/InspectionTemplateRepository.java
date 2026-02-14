package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import ye.gov.sanaa.healthoffice.entity.InspectionTemplate;

import java.util.Optional;

@Repository
public interface InspectionTemplateRepository extends JpaRepository<InspectionTemplate, Long> {
    Optional<InspectionTemplate> findByFacilityType(String facilityType);
}
