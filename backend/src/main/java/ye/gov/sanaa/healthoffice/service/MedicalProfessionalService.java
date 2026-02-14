package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ye.gov.sanaa.healthoffice.dto.MedicalProfessionalDto;
import ye.gov.sanaa.healthoffice.dto.StaffAssignmentDto;
import ye.gov.sanaa.healthoffice.entity.Facility;
import ye.gov.sanaa.healthoffice.entity.FacilityStaff;
import ye.gov.sanaa.healthoffice.entity.MedicalProfessional;
import ye.gov.sanaa.healthoffice.repository.FacilityRepository;
import ye.gov.sanaa.healthoffice.repository.FacilityStaffRepository;
import ye.gov.sanaa.healthoffice.repository.MedicalProfessionalRepository;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class MedicalProfessionalService {

    private final MedicalProfessionalRepository professionalRepository;
    private final FacilityStaffRepository staffRepository;
    private final FacilityRepository facilityRepository;

    @Transactional
    public MedicalProfessionalDto createProfessional(MedicalProfessionalDto dto) {
        if (professionalRepository.findByNationalId(dto.getNationalId()).isPresent()) {
            throw new RuntimeException("Medical Professional with this National ID already exists");
        }
        if (professionalRepository.findByPracticeLicenseNumber(dto.getPracticeLicenseNumber()).isPresent()) {
            throw new RuntimeException("Medical Professional with this License Number already exists");
        }

        MedicalProfessional entity = MedicalProfessional.builder()
                .nationalId(dto.getNationalId())
                .fullNameAr(dto.getFullNameAr())
                .fullNameEn(dto.getFullNameEn())
                .phoneNumber(dto.getPhoneNumber())
                .email(dto.getEmail())
                .qualification(dto.getQualification())
                .specialization(dto.getSpecialization())
                .university(dto.getUniversity())
                .graduationYear(dto.getGraduationYear())
                .practiceLicenseNumber(dto.getPracticeLicenseNumber())
                .licenseIssueDate(dto.getLicenseIssueDate())
                .licenseExpiryDate(dto.getLicenseExpiryDate())
                .build();

        entity = professionalRepository.save(entity);
        dto.setId(entity.getId());
        return dto;
    }

    public List<MedicalProfessionalDto> searchProfessionals(String query) {
        // This is a simple implementation. In a real scenario, use a custom query or
        // Specification.
        // For now, assuming query is National ID or License Number
        Optional<MedicalProfessional> byNationalId = professionalRepository.findByNationalId(query);
        if (byNationalId.isPresent()) {
            return List.of(mapToDto(byNationalId.get()));
        }
        Optional<MedicalProfessional> byLicense = professionalRepository.findByPracticeLicenseNumber(query);
        if (byLicense.isPresent()) {
            return List.of(mapToDto(byLicense.get()));
        }
        return List.of();
    }

    @Transactional
    public void assignStaffToFacility(StaffAssignmentDto dto) {
        MedicalProfessional professional = professionalRepository.findById(dto.getMedicalProfessionalId())
                .orElseThrow(() -> new RuntimeException("Medical Professional not found"));

        Facility facility = facilityRepository.findById(dto.getFacilityId())
                .orElseThrow(() -> new RuntimeException("Facility not found"));

        // Validation: Check License Expiry
        if (professional.getLicenseExpiryDate().isBefore(LocalDate.now())) {
            throw new RuntimeException("Cannot assign staff: Professional Practice License is expired");
        }

        // Validation: Unique Technical Manager rule
        if (dto.getIsTechnicalManager()) {
            boolean isManagerElsewhere = staffRepository.isActiveTechnicalManagerElsewhere(professional.getId(),
                    LocalDate.now());
            if (isManagerElsewhere) {
                throw new RuntimeException(
                        "This professional is already an active Technical Manager in another facility.");
            }
        }

        FacilityStaff staff = FacilityStaff.builder()
                .facility(facility)
                .medicalProfessional(professional)
                .jobTitle(dto.getJobTitle())
                .isTechnicalManager(dto.getIsTechnicalManager())
                .contractType(dto.getContractType())
                .contractStartDate(dto.getContractStartDate())
                .contractEndDate(dto.getContractEndDate())
                .isActive(true)
                .build();

        staffRepository.save(staff);
    }

    private MedicalProfessionalDto mapToDto(MedicalProfessional entity) {
        MedicalProfessionalDto dto = new MedicalProfessionalDto();
        dto.setId(entity.getId());
        dto.setNationalId(entity.getNationalId());
        dto.setFullNameAr(entity.getFullNameAr());
        dto.setFullNameEn(entity.getFullNameEn());
        dto.setPhoneNumber(entity.getPhoneNumber());
        dto.setEmail(entity.getEmail());
        dto.setQualification(entity.getQualification());
        dto.setSpecialization(entity.getSpecialization());
        dto.setUniversity(entity.getUniversity());
        dto.setGraduationYear(entity.getGraduationYear());
        dto.setPracticeLicenseNumber(entity.getPracticeLicenseNumber());
        dto.setLicenseIssueDate(entity.getLicenseIssueDate());
        dto.setLicenseExpiryDate(entity.getLicenseExpiryDate());
        return dto;
    }
}
