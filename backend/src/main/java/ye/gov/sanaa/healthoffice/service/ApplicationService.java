package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ye.gov.sanaa.healthoffice.dto.*;
import ye.gov.sanaa.healthoffice.entity.*;
import ye.gov.sanaa.healthoffice.repository.*;

import java.time.OffsetDateTime;
import java.time.LocalDate;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ApplicationService {

    private final ApplicationRepository applicationRepository;
    private final ApplicationStepRepository applicationStepRepository;
    private final ApplicationDocumentRepository applicationDocumentRepository;
    private final FacilityRepository facilityRepository;
    private final FacilityUserRepository facilityUserRepository;
    private final AuditService auditService;
    private final NotificationService notificationService;
    private final LicenseRepository licenseRepository;
    private final ViolationRepository violationRepository;

    private LocalDate parseDate(String date) {
        if (date == null || date.trim().isEmpty())
            return null;
        try {
            return LocalDate.parse(date);
        } catch (Exception e) {
            return null;
        }
    }

    private static final List<String> WORKFLOW_STEPS = List.of(
            "DRAFT", "SUBMIT", "LICENSING_REVIEW", "BLUEPRINT_REVIEW", "INSPECTION_SCHEDULING",
            "INSPECTION_REPORT", "COMMITTEE_APPROVAL", "PAYMENT_ORDER",
            "ELECTRONIC_PAYMENT", "LICENSE_ISSUANCE", "ARCHIVE");

    @Transactional
    public ApplicationDto createDraft(Long facilityId, Long userId, ApplicationDto dto) {
        Facility facility = facilityRepository.findById(facilityId)
                .orElseThrow(() -> new RuntimeException("Facility not found"));

        String appNumber = "APP-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

        Application app = Application.builder()
                .applicationNumber(appNumber)
                .facility(facility)
                .submittedByUser(facilityUserRepository.findById(userId).orElse(null))
                .status("DRAFT")
                .licenseType(dto.getLicenseType())
                .facilityType(dto.getFacilityType())
                .supervisorName(dto.getSupervisorName())
                .supervisorPhone(dto.getSupervisorPhone())
                .supervisorNationalId(dto.getSupervisorNationalId())
                .supervisorIdIssuer(dto.getSupervisorIdIssuer())
                .supervisorIdIssueDate(parseDate(dto.getSupervisorIdIssueDate()))
                .supervisorQualification(dto.getSupervisorQualification())
                .supervisorUniversity(dto.getSupervisorUniversity())
                .supervisorQualIssuer(dto.getSupervisorQualIssuer())
                .supervisorQualDate(parseDate(dto.getSupervisorQualDate()))
                .supervisorPracticeLicense(dto.getSupervisorPracticeLicense())
                .supervisorLicenseExpiry(parseDate(dto.getSupervisorLicenseExpiry()))
                .prevIssuingAuthority(dto.getPrevIssuingAuthority())
                .prevLicenseNumber(dto.getPrevLicenseNumber())
                .prevLicenseDate(parseDate(dto.getPrevLicenseDate()))
                .prevValidityPeriod(dto.getPrevValidityPeriod())
                .build();

        app = applicationRepository.save(app);

        // Create initial workflow step
        ApplicationStep draftStep = ApplicationStep.builder()
                .application(app)
                .stepOrder(1)
                .stepCode("DRAFT")
                .status("COMPLETED")
                .performedByUser(app.getSubmittedByUser())
                .performedAt(OffsetDateTime.now())
                .notes("Application created as draft")
                .build();
        applicationStepRepository.save(draftStep);

        auditService.log(null, userId, "CREATE_APPLICATION", "APPLICATION", app.getId(),
                "Draft application created: " + appNumber);

        return toDto(app);
    }

    @Transactional
    public ApplicationDto submitApplication(Long applicationId, Long userId) {
        Application app = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found"));

        if (!"DRAFT".equals(app.getStatus())) {
            throw new RuntimeException("Application can only be submitted from DRAFT status");
        }

        app.setStatus("SUBMITTED");
        app.setSubmittedAt(OffsetDateTime.now());
        applicationRepository.save(app);

        ApplicationStep submitStep = ApplicationStep.builder()
                .application(app)
                .stepOrder(2)
                .stepCode("SUBMIT")
                .status("COMPLETED")
                .performedByUser(facilityUserRepository.findById(userId).orElse(null))
                .performedAt(OffsetDateTime.now())
                .notes("Application submitted for review")
                .build();
        applicationStepRepository.save(submitStep);

        auditService.log(null, userId, "SUBMIT_APPLICATION", "APPLICATION", app.getId(),
                "Application submitted: " + app.getApplicationNumber());

        notificationService.notifyUser(userId, "تم تقديم الطلب بنجاح", "Application Submitted Successfully",
                "رقم الطلب: " + app.getApplicationNumber(), "App No: " + app.getApplicationNumber(), "INFO");

        return toDto(app);
    }

    @Transactional
    public ApplicationDto advanceWorkflow(Long applicationId, Long adminId, String notes) {
        Application app = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found"));

        String currentStatus = app.getStatus();

        // STRICT WORKFLOW ENFORCEMENT
        if ("INSPECTION_SCHEDULED".equals(currentStatus)) {
            throw new RuntimeException("Cannot manually advance. Must complete inspection.");
        }
        if ("COMMITTEE_APPROVED".equals(currentStatus)) {
            throw new RuntimeException("Cannot manually advance. Must generate payment order.");
        }
        if ("PAYMENT_PENDING".equals(currentStatus)) {
            throw new RuntimeException("Cannot manually advance. Must confirm payment.");
        }

        int currentIndex = getStatusIndex(currentStatus);
        if (currentIndex < 0 || currentIndex >= WORKFLOW_STEPS.size() - 1) {
            throw new RuntimeException("Cannot advance from current status: " + currentStatus);
        }

        String nextStep = WORKFLOW_STEPS.get(currentIndex + 1);
        String nextStatus = mapStepToStatus(nextStep);
        app.setStatus(nextStatus);

        if ("LICENSE_ISSUED".equals(nextStatus)) {
            app.setApprovedAt(OffsetDateTime.now());

            // Create the actual License record
            String licenseNum = "LIC-" + app.getApplicationNumber().replace("APP-", "");
            License license = License.builder()
                    .application(app)
                    .licenseNumber(licenseNum)
                    .issueDate(LocalDate.now())
                    .expiryDate(LocalDate.now().plusYears(1))
                    .pdfUrl("generated_license_" + licenseNum + ".pdf")
                    .status("ACTIVE")
                    .build();
            licenseRepository.save(license);
        }

        applicationRepository.save(app);

        ApplicationStep step = ApplicationStep.builder()
                .application(app)
                .stepOrder(currentIndex + 2)
                .stepCode(nextStep)
                .status("COMPLETED")
                .performedByAdmin(null)
                .performedAt(OffsetDateTime.now())
                .notes(notes)
                .build();

        // Set admin reference properly
        step.setPerformedByAdmin(null); // Will be set in controller context
        applicationStepRepository.save(step);

        auditService.log(adminId, null, "ADVANCE_WORKFLOW", "APPLICATION", app.getId(),
                "Advanced to: " + nextStep);

        // Notify User based on step
        if ("COMMITTEE_APPROVED".equals(nextStatus)) {
            notificationService.notifyUser(app.getSubmittedByUser().getId(),
                    "تمت موافقة اللجنة", "Committee Approved",
                    "يرجى استكمال إجراءات الدفع", "Please proceed to payment", "SUCCESS");
        } else if ("LICENSE_ISSUED".equals(nextStatus)) {
            notificationService.notifyUser(app.getSubmittedByUser().getId(),
                    "تم إصدار الترخيص", "License Issued",
                    "يمكنك استلام الترخيص الآن", "You can collect your license now", "SUCCESS");
        }

        return toDto(app);
    }

    @Transactional
    public ApplicationDto rejectApplication(Long applicationId, Long adminId, String reason) {
        Application app = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found"));

        app.setStatus("REJECTED");
        app.setRejectedAt(OffsetDateTime.now());
        app.setRejectionReason(reason);
        applicationRepository.save(app);

        auditService.log(adminId, null, "REJECT_APPLICATION", "APPLICATION", app.getId(),
                "Rejected: " + reason);

        notificationService.notifyUser(app.getSubmittedByUser().getId(),
                "تم رفض الطلب", "Application Rejected",
                "السبب: " + reason, "Reason: " + reason, "ERROR");

        return toDto(app);
    }

    @Transactional(readOnly = true)
    public ApplicationDto getById(Long id) {
        Application app = applicationRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Application not found"));
        ApplicationDto dto = toDto(app);
        dto.setSteps(getSteps(id));
        dto.setDocuments(getDocuments(id));

        licenseRepository.findByApplicationId(id).stream()
                .findFirst()
                .ifPresent(l -> dto.setLicense(toLicenseDto(l)));

        return dto;
    }

    @Transactional(readOnly = true)
    public Page<ApplicationDto> getByStatus(String status, Pageable pageable) {
        return applicationRepository.findByStatus(status, pageable).map(this::toDto);
    }

    @Transactional(readOnly = true)
    public Page<ApplicationDto> getByFacility(Long facilityId, Pageable pageable) {
        return applicationRepository.findByFacilityId(facilityId, pageable).map(this::toDto);
    }

    @Transactional(readOnly = true)
    public Page<ApplicationDto> getAll(Pageable pageable) {
        return applicationRepository.findAll(pageable).map(this::toDto);
    }

    @Transactional(readOnly = true)
    public List<ApplicationStepDto> getSteps(Long applicationId) {
        return applicationStepRepository.findByApplicationIdOrderByStepOrderAsc(applicationId)
                .stream().map(this::toStepDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<ApplicationDocumentDto> getDocuments(Long applicationId) {
        return applicationDocumentRepository.findByApplicationId(applicationId)
                .stream().map(this::toDocDto).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public Page<LicenseDto> getAllLicenses(Pageable pageable) {
        return licenseRepository.findAll(pageable).map(this::toLicenseDto);
    }

    @Transactional(readOnly = true)
    public Page<ViolationDto> getAllViolations(Pageable pageable) {
        // Assuming ViolationRepository is available or using a generic approach
        // Wait, ViolationRepository is NOT in ApplicationService. I should add it.
        return violationRepository.findAll(pageable).map(this::toViolationDto);
    }

    @Transactional
    public ApplicationDocumentDto addDocument(Long applicationId, Long userId, ApplicationDocumentDto dto) {
        Application app = applicationRepository.findById(applicationId)
                .orElseThrow(() -> new RuntimeException("Application not found"));

        FacilityUser user = facilityUserRepository.findById(userId)
                .orElseThrow(() -> new RuntimeException("User not found"));

        ApplicationDocument doc = ApplicationDocument.builder()
                .application(app)
                .documentType(dto.getDocumentType())
                .fileUrl(dto.getFileUrl())
                .isMandatory(dto.getIsMandatory() != null ? dto.getIsMandatory() : true)
                .uploadedByUser(user)
                .build();

        doc = applicationDocumentRepository.save(doc);
        return toDocDto(doc);
    }

    private int getStatusIndex(String status) {
        String step = mapStatusToStep(status);
        return WORKFLOW_STEPS.indexOf(step);
    }

    private String mapStepToStatus(String step) {
        return switch (step) {
            case "DRAFT" -> "DRAFT";
            case "SUBMIT" -> "SUBMITTED";
            case "LICENSING_REVIEW" -> "UNDER_REVIEW";
            case "BLUEPRINT_REVIEW" -> "BLUEPRINT_REVIEW";
            case "INSPECTION_SCHEDULING" -> "INSPECTION_SCHEDULED";
            case "INSPECTION_REPORT" -> "INSPECTION_COMPLETED";
            case "COMMITTEE_APPROVAL" -> "COMMITTEE_APPROVED";
            case "PAYMENT_ORDER" -> "PAYMENT_PENDING";
            case "ELECTRONIC_PAYMENT" -> "PAYMENT_COMPLETED";
            case "LICENSE_ISSUANCE" -> "LICENSE_ISSUED";
            case "ARCHIVE" -> "ARCHIVED";
            default -> step;
        };
    }

    private String mapStatusToStep(String status) {
        return switch (status) {
            case "DRAFT" -> "DRAFT";
            case "SUBMITTED" -> "SUBMIT";
            case "UNDER_REVIEW" -> "LICENSING_REVIEW";
            case "BLUEPRINT_REVIEW" -> "BLUEPRINT_REVIEW";
            case "INSPECTION_SCHEDULED" -> "INSPECTION_SCHEDULING";
            case "INSPECTION_COMPLETED" -> "INSPECTION_REPORT";
            case "COMMITTEE_APPROVED" -> "COMMITTEE_APPROVAL";
            case "PAYMENT_PENDING" -> "PAYMENT_ORDER";
            case "PAYMENT_COMPLETED" -> "ELECTRONIC_PAYMENT";
            case "LICENSE_ISSUED" -> "LICENSE_ISSUANCE";
            case "ARCHIVED" -> "ARCHIVE";
            default -> status;
        };
    }

    private ApplicationDto toDto(Application app) {
        return ApplicationDto.builder()
                .id(app.getId())
                .applicationNumber(app.getApplicationNumber())
                .facilityId(app.getFacility().getId())
                .facilityNameAr(app.getFacility().getNameAr())
                .facilityNameEn(app.getFacility().getNameEn())
                .status(app.getStatus())
                .licenseType(app.getLicenseType())
                .facilityType(app.getFacilityType())
                // Section B
                .supervisorName(app.getSupervisorName())
                .supervisorPhone(app.getSupervisorPhone())
                .supervisorNationalId(app.getSupervisorNationalId())
                .supervisorIdIssuer(app.getSupervisorIdIssuer())
                .supervisorIdIssueDate(
                        app.getSupervisorIdIssueDate() != null ? app.getSupervisorIdIssueDate().toString() : null)
                .supervisorQualification(app.getSupervisorQualification())
                .supervisorUniversity(app.getSupervisorUniversity())
                .supervisorQualIssuer(app.getSupervisorQualIssuer())
                .supervisorQualDate(app.getSupervisorQualDate() != null ? app.getSupervisorQualDate().toString() : null)
                .supervisorPracticeLicense(app.getSupervisorPracticeLicense())
                .supervisorLicenseExpiry(
                        app.getSupervisorLicenseExpiry() != null ? app.getSupervisorLicenseExpiry().toString() : null)
                // Section C
                .prevIssuingAuthority(app.getPrevIssuingAuthority())
                .prevLicenseNumber(app.getPrevLicenseNumber())
                .prevLicenseDate(app.getPrevLicenseDate() != null ? app.getPrevLicenseDate().toString() : null)
                .prevValidityPeriod(app.getPrevValidityPeriod())
                // Meta
                .createdAt(app.getCreatedAt())
                .submittedAt(app.getSubmittedAt())
                .approvedAt(app.getApprovedAt())
                .rejectionReason(app.getRejectionReason())
                // Relations
                .steps(applicationStepRepository.findByApplicationIdOrderByStepOrderAsc(app.getId()).stream()
                        .map(this::toStepDto).collect(Collectors.toList()))
                .documents(applicationDocumentRepository.findByApplicationId(app.getId()).stream()
                        .map(this::toDocDto).collect(Collectors.toList()))
                .license(licenseRepository.findByApplicationId(app.getId()).stream()
                        .findFirst().map(this::toLicenseDto).orElse(null))
                .build();
    }

    private ApplicationStepDto toStepDto(ApplicationStep step) {
        String performedBy = "";
        if (step.getPerformedByAdmin() != null)
            performedBy = step.getPerformedByAdmin().getFullName();
        if (step.getPerformedByUser() != null)
            performedBy = step.getPerformedByUser().getFullName();
        return ApplicationStepDto.builder()
                .id(step.getId())
                .stepOrder(step.getStepOrder())
                .stepCode(step.getStepCode())
                .status(step.getStatus())
                .performedByName(performedBy)
                .performedAt(step.getPerformedAt())
                .notes(step.getNotes())
                .build();
    }

    private ApplicationDocumentDto toDocDto(ApplicationDocument doc) {
        return ApplicationDocumentDto.builder()
                .id(doc.getId())
                .documentType(doc.getDocumentType())
                .referenceNumber(doc.getReferenceNumber())
                .issueDate(doc.getIssueDate() != null ? doc.getIssueDate().toString() : null)
                .isMandatory(doc.getIsMandatory())
                .fileUrl(doc.getFileUrl())
                .build();
    }

    private LicenseDto toLicenseDto(License l) {
        return LicenseDto.builder()
                .id(l.getId())
                .applicationId(l.getApplication().getId())
                .applicationNumber(l.getApplication().getApplicationNumber())
                .facilityNameAr(l.getApplication().getFacility().getNameAr())
                .licenseNumber(l.getLicenseNumber())
                .issueDate(l.getIssueDate())
                .expiryDate(l.getExpiryDate())
                .pdfUrl(l.getPdfUrl())
                .status(l.getStatus())
                .build();
    }

    private ViolationDto toViolationDto(Violation v) {
        return ViolationDto.builder()
                .id(v.getId())
                .applicationId(v.getApplication() != null ? v.getApplication().getId() : null)
                .facilityNameAr(v.getApplication() != null ? v.getApplication().getFacility().getNameAr() : "")
                .code(v.getCode())
                .description(v.getDescription())
                .penalty(v.getPenalty())
                .severity(v.getSeverity())
                .isActive(v.getIsActive())
                .createdAt(v.getCreatedAt())
                .build();
    }
}
