package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ye.gov.sanaa.healthoffice.entity.FacilityUser;
import java.util.Optional;
import java.util.List;

public interface FacilityUserRepository extends JpaRepository<FacilityUser, Long> {
    Optional<FacilityUser> findByPhoneNumber(String phoneNumber);

    List<FacilityUser> findByFacilityId(Long facilityId);

    boolean existsByPhoneNumber(String phoneNumber);
}
