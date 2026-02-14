package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import ye.gov.sanaa.healthoffice.entity.MedicalProfessional;

import java.util.Optional;

@Repository
public interface MedicalProfessionalRepository extends JpaRepository<MedicalProfessional, Long> {
    Optional<MedicalProfessional> findByNationalId(String nationalId);

    Optional<MedicalProfessional> findByPracticeLicenseNumber(String practiceLicenseNumber);
}
