package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import ye.gov.sanaa.healthoffice.entity.FacilityStaff;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface FacilityStaffRepository extends JpaRepository<FacilityStaff, Long> {
        List<FacilityStaff> findByFacilityId(Long facilityId);

        List<FacilityStaff> findByMedicalProfessionalId(Long medicalProfessionalId);

        // Find active staff records for a professional
        @Query("SELECT fs FROM FacilityStaff fs WHERE fs.medicalProfessional.id = :profId AND fs.isActive = true AND (fs.contractEndDate IS NULL OR fs.contractEndDate >= :currentDate)")
        List<FacilityStaff> findActiveByProfessional(@Param("profId") Long profId,
                        @Param("currentDate") LocalDate currentDate);

        // Check if professional is already a technical manager somewhere else actively
        @Query("SELECT COUNT(fs) > 0 FROM FacilityStaff fs WHERE fs.medicalProfessional.id = :profId AND fs.isTechnicalManager = true AND fs.isActive = true AND (fs.contractEndDate IS NULL OR fs.contractEndDate >= :currentDate)")
        boolean isActiveTechnicalManagerElsewhere(@Param("profId") Long profId,
                        @Param("currentDate") LocalDate currentDate);
}
