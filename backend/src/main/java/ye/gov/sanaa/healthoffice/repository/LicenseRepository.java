package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ye.gov.sanaa.healthoffice.entity.License;
import java.util.Optional;
import java.util.List;

public interface LicenseRepository extends JpaRepository<License, Long> {
    Optional<License> findByLicenseNumber(String licenseNumber);

    List<License> findByApplicationId(Long applicationId);

    long countByExpiryDateBefore(java.time.LocalDate date);
}
