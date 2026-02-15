package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ye.gov.sanaa.healthoffice.entity.Facility;
import java.util.Optional;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface FacilityRepository extends JpaRepository<Facility, Long> {
    Optional<Facility> findByFacilityCode(String facilityCode);

    List<Facility> findByFacilityType(String facilityType);

    List<Facility> findByIsActiveTrue();

    Page<Facility> findByGovernorate(String governorate, Pageable pageable);

    Page<Facility> findByDistrict(String district, Pageable pageable);

    Page<Facility> findByOperationalStatus(String operationalStatus, Pageable pageable);

    Page<Facility> findByFacilityTypeAndOperationalStatus(String facilityType, String operationalStatus, Pageable pageable);
}
