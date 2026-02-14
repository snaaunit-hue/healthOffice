package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ye.gov.sanaa.healthoffice.entity.Facility;
import java.util.Optional;
import java.util.List;

public interface FacilityRepository extends JpaRepository<Facility, Long> {
    Optional<Facility> findByFacilityCode(String facilityCode);

    List<Facility> findByFacilityType(String facilityType);

    List<Facility> findByIsActiveTrue();
}
