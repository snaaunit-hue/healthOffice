package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import ye.gov.sanaa.healthoffice.entity.Application;
import java.util.Optional;
import java.util.List;

public interface ApplicationRepository extends JpaRepository<Application, Long> {
    Optional<Application> findByApplicationNumber(String applicationNumber);

    List<Application> findByFacilityId(Long facilityId);

    Page<Application> findByStatus(String status, Pageable pageable);

    Page<Application> findByFacilityId(Long facilityId, Pageable pageable);

    long countByStatus(String status);
}
