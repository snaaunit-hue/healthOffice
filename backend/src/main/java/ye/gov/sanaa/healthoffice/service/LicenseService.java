package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ye.gov.sanaa.healthoffice.dto.LicenseDto;
import ye.gov.sanaa.healthoffice.dto.PublicLicenseDto;
import ye.gov.sanaa.healthoffice.entity.*;
import ye.gov.sanaa.healthoffice.repository.*;

import java.io.*;
import java.nio.file.*;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * Service for license lifecycle management:
 * - PDF generation (A4 portrait, Arabic layout)
 * - QR code embedding with public verification URL
 * - Reprint, invalidation, update operations
 * - Full audit trail
 */
@Service
@RequiredArgsConstructor
public class LicenseService {

        private final LicenseRepository licenseRepository;
        private final ApplicationRepository applicationRepository;
        private final AuditService auditService;
        private final NotificationService notificationService;
        private final SystemSettingRepository systemSettingRepository;

        private static final String BASE_VERIFY_URL = "http://localhost:8080/public/verify/";
        private static final DateTimeFormatter AR_DATE_FMT = DateTimeFormatter.ofPattern("yyyy/MM/dd");

        /**
         * Generate official license PDF for an application.
         * Called after LICENSE_ISSUED status is set.
         */
        @Transactional
        public LicenseDto generateLicensePdf(Long applicationId, Long adminId) {
                Application app = applicationRepository.findById(applicationId)
                                .orElseThrow(() -> new RuntimeException("Application not found"));

                if (!"LICENSE_ISSUED".equals(app.getStatus()) && !"PAYMENT_COMPLETED".equals(app.getStatus())) {
                        throw new RuntimeException(
                                        "License can only be generated after payment completion or license issuance. Current: "
                                                        + app.getStatus());
                }

                // Find or create the license record
                List<License> existing = licenseRepository.findByApplicationId(applicationId);
                License license;
                if (!existing.isEmpty()) {
                        license = existing.get(0);
                } else {
                        // Create license record
                        String licenseNumber = generateLicenseNumber(app);
                        license = License.builder()
                                        .application(app)
                                        .licenseNumber(licenseNumber)
                                        .issueDate(LocalDate.now())
                                        .expiryDate(LocalDate.now().plusYears(1))
                                        .pdfUrl("")
                                        .status("ACTIVE")
                                        .build();
                        license = licenseRepository.save(license);
                }

                // Generate PDF content as HTML (will be rendered by a print-ready viewer)
                String pdfFileName = generateLicenseHtml(app, license);
                license.setPdfUrl(pdfFileName);
                licenseRepository.save(license);

                auditService.log(adminId, null, "GENERATE_LICENSE_PDF", "LICENSE", license.getId(),
                                "License PDF generated: " + license.getLicenseNumber());

                notificationService.notifyUser(app.getSubmittedByUser().getId(),
                                "تم إصدار الترخيص", "License Issued",
                                "تم إصدار ترخيصك رقم: " + license.getLicenseNumber(),
                                "Your license #" + license.getLicenseNumber() + " has been issued.",
                                "SUCCESS");

                return toDto(license);
        }

        /**
         * Reprint (regenerate) an existing license PDF.
         */
        @Transactional
        public LicenseDto reprintLicense(Long licenseId, Long adminId) {
                License license = licenseRepository.findById(licenseId)
                                .orElseThrow(() -> new RuntimeException("License not found"));

                Application app = license.getApplication();
                String pdfFileName = generateLicenseHtml(app, license);
                license.setPdfUrl(pdfFileName);
                licenseRepository.save(license);

                auditService.log(adminId, null, "REPRINT_LICENSE", "LICENSE", license.getId(),
                                "License reprinted: " + license.getLicenseNumber());

                return toDto(license);
        }

        /**
         * Invalidate/Revoke a license.
         */
        @Transactional
        public LicenseDto invalidateLicense(Long licenseId, Long adminId, String reason) {
                License license = licenseRepository.findById(licenseId)
                                .orElseThrow(() -> new RuntimeException("License not found"));

                license.setStatus("REVOKED");
                licenseRepository.save(license);

                auditService.log(adminId, null, "INVALIDATE_LICENSE", "LICENSE", license.getId(),
                                "License revoked: " + license.getLicenseNumber() + ". Reason: " + reason);

                Application app = license.getApplication();
                notificationService.notifyUser(app.getSubmittedByUser().getId(),
                                "تم إلغاء الترخيص", "License Revoked",
                                "تم إلغاء ترخيصك رقم: " + license.getLicenseNumber() + " - السبب: " + reason,
                                "Your license #" + license.getLicenseNumber() + " has been revoked. Reason: " + reason,
                                "WARNING");

                return toDto(license);
        }

        /**
         * Update license dates (renewal / extension).
         */
        @Transactional
        public LicenseDto updateLicenseDates(Long licenseId, Long adminId,
                        LocalDate newIssueDate, LocalDate newExpiryDate) {
                License license = licenseRepository.findById(licenseId)
                                .orElseThrow(() -> new RuntimeException("License not found"));

                if (newExpiryDate.isBefore(newIssueDate)) {
                        throw new RuntimeException("Expiry date must be after issue date");
                }

                license.setIssueDate(newIssueDate);
                license.setExpiryDate(newExpiryDate);
                license.setStatus("ACTIVE");
                licenseRepository.save(license);

                // Regenerate PDF with new dates
                Application app = license.getApplication();
                String pdfFileName = generateLicenseHtml(app, license);
                license.setPdfUrl(pdfFileName);
                licenseRepository.save(license);

                auditService.log(adminId, null, "UPDATE_LICENSE", "LICENSE", license.getId(),
                                "License updated: " + license.getLicenseNumber()
                                                + " new expiry: " + newExpiryDate);

                return toDto(license);
        }

        /**
         * Public verification endpoint data.
         */
        @Transactional(readOnly = true)
        public PublicLicenseDto verifyLicense(String licenseNumber) {
                License license = licenseRepository.findByLicenseNumber(licenseNumber)
                                .orElseThrow(() -> new RuntimeException("License not found"));

                Application app = license.getApplication();
                Facility facility = app.getFacility();
                boolean isValid = "ACTIVE".equals(license.getStatus())
                                && !license.getExpiryDate().isBefore(LocalDate.now());

                return PublicLicenseDto.builder()
                                .facilityName(facility.getNameAr())
                                .licenseNumber(license.getLicenseNumber())
                                .facilityType(app.getFacilityType())
                                .status(license.getStatus())
                                .issueDate(license.getIssueDate())
                                .expiryDate(license.getExpiryDate())
                                .isValid(isValid)
                                .district(facility.getDistrict())
                                .supervisorName(app.getSupervisorName())
                                .build();
        }

        @Transactional(readOnly = true)
        public LicenseDto getByApplication(Long applicationId) {
                List<License> licenses = licenseRepository.findByApplicationId(applicationId);
                if (licenses.isEmpty()) {
                        throw new RuntimeException("No license found for application " + applicationId);
                }
                return toDto(licenses.get(0));
        }

        // ══════════════════════════════════════════
        // PRIVATE HELPERS
        // ══════════════════════════════════════════

        private String generateLicenseNumber(Application app) {
                String year = String.valueOf(LocalDate.now().getYear());
                String seq = String.format("%05d", app.getId());
                return "LIC-" + year + "-" + seq;
        }

        /**
         * Generates an HTML file that represents the official license document.
         * A4 portrait, Arabic layout, includes QR code placeholder.
         * In production this would use a PDF library like iText or Apache PDFBox;
         * for now we generate print-ready HTML that can be converted to PDF.
         */
        private String generateLicenseHtml(Application app, License license) {
                String verifyUrl = BASE_VERIFY_URL + license.getLicenseNumber();

                Facility facility = app.getFacility();
                String facilityTypeAr = mapFacilityTypeAr(app.getFacilityType());
                String issueStr = license.getIssueDate().format(AR_DATE_FMT);
                String expiryStr = license.getExpiryDate().format(AR_DATE_FMT);

                // Determine fee
                String fee = systemSettingRepository
                                .findByCategoryAndSettingKey("FEES", "LICENSE_FEE_" + app.getFacilityType())
                                .map(SystemSetting::getSettingValue)
                                .orElse("150,000");

                String html = """
                                <!DOCTYPE html>
                                <html dir="rtl" lang="ar">
                                <head>
                                <meta charset="UTF-8">
                                <title>ترخيص منشأة صحية - %s</title>
                                <style>
                                  @page { size: A4 portrait; margin: 15mm; }
                                  @media print { body { -webkit-print-color-adjust: exact; print-color-adjust: exact; } }
                                  * { margin: 0; padding: 0; box-sizing: border-box; }
                                  body { font-family: 'Amiri', 'Traditional Arabic', serif; direction: rtl; background: #fff; color: #1a1a1a; width: 210mm; min-height: 297mm; padding: 12mm; }
                                  .header { text-align: center; border-bottom: 3px double #1b5e20; padding-bottom: 12px; margin-bottom: 16px; }
                                  .header h1 { font-size: 20pt; color: #1b5e20; margin-bottom: 4px; }
                                  .header h2 { font-size: 14pt; color: #333; margin-bottom: 2px; }
                                  .header h3 { font-size: 12pt; color: #555; }
                                  .republic { font-size: 10pt; color: #888; }
                                  .license-title { text-align: center; margin: 16px 0; font-size: 22pt; color: #1b5e20; font-weight: bold; border: 2px solid #1b5e20; padding: 8px 24px; display: inline-block; }
                                  .title-wrap { text-align: center; margin-bottom: 16px; }
                                  .info-table { width: 100%%; border-collapse: collapse; margin: 12px 0; }
                                  .info-table td { padding: 6px 12px; border: 1px solid #ccc; font-size: 11pt; }
                                  .info-table td.label { background: #f5f5f5; font-weight: bold; width: 35%%; color: #1b5e20; }
                                  .section-title { font-size: 13pt; color: #1b5e20; font-weight: bold; margin: 16px 0 8px; border-bottom: 1px solid #1b5e20; padding-bottom: 4px; }
                                  .footer { margin-top: 24px; border-top: 3px double #1b5e20; padding-top: 12px; text-align: center; }
                                  .footer .notice { font-size: 9pt; color: #c62828; font-weight: bold; margin-top: 8px; }
                                  .qr-section { text-align: center; margin: 16px 0; }
                                  .qr-section img { width: 100px; height: 100px; }
                                  .qr-label { font-size: 8pt; color: #666; }
                                  .signatures { display: flex; justify-content: space-between; margin-top: 24px; }
                                  .sig-box { width: 45%%; text-align: center; }
                                  .sig-box .sig-line { border-top: 1px solid #333; margin-top: 40px; padding-top: 4px; font-size: 10pt; }
                                  .stamp { text-align: center; margin-top: 12px; }
                                  .stamp-circle { width: 80px; height: 80px; border: 2px solid #1b5e20; border-radius: 50%%; display: inline-block; line-height: 80px; font-size: 8pt; color: #1b5e20; }
                                </style>
                                </head>
                                <body>
                                  <div class="header">
                                    <div class="republic">الجمهورية اليمنية</div>
                                    <h1>مكتب الصحة والبيئة</h1>
                                    <h2>أمانة العاصمة صنعاء</h2>
                                    <h3>إدارة التراخيص الصحية</h3>
                                  </div>

                                  <div class="title-wrap">
                                    <div class="license-title">ترخيص منشأة صحية</div>
                                  </div>

                                  <div class="section-title">بيانات الترخيص</div>
                                  <table class="info-table">
                                    <tr><td class="label">رقم الترخيص</td><td>%s</td></tr>
                                    <tr><td class="label">تاريخ الإصدار</td><td>%s</td></tr>
                                    <tr><td class="label">تاريخ الانتهاء</td><td>%s</td></tr>
                                    <tr><td class="label">نوع الترخيص</td><td>%s</td></tr>
                                  </table>

                                  <div class="section-title">بيانات المنشأة</div>
                                  <table class="info-table">
                                    <tr><td class="label">اسم المنشأة</td><td>%s</td></tr>
                                    <tr><td class="label">نوع المنشأة</td><td>%s</td></tr>
                                    <tr><td class="label">المديرية</td><td>%s</td></tr>
                                    <tr><td class="label">العنوان</td><td>%s</td></tr>
                                    <tr><td class="label">رقم الطلب</td><td>%s</td></tr>
                                  </table>

                                  <div class="section-title">بيانات المشرف الفني</div>
                                  <table class="info-table">
                                    <tr><td class="label">الاسم</td><td>%s</td></tr>
                                    <tr><td class="label">رقم الهوية</td><td>%s</td></tr>
                                    <tr><td class="label">المؤهل</td><td>%s</td></tr>
                                    <tr><td class="label">رقم مزاولة المهنة</td><td>%s</td></tr>
                                  </table>

                                  <div class="section-title">الرسوم</div>
                                  <table class="info-table">
                                    <tr><td class="label">رسوم الترخيص</td><td>%s ر.ي</td></tr>
                                  </table>

                                  <div class="qr-section">
                                    <img src="https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=%s" alt="QR Code" />
                                    <div class="qr-label">امسح الرمز للتحقق من صلاحية الترخيص</div>
                                  </div>

                                  <div class="signatures">
                                    <div class="sig-box">
                                      <div class="sig-line">مدير إدارة التراخيص</div>
                                    </div>
                                    <div class="sig-box">
                                      <div class="sig-line">مدير عام المكتب</div>
                                    </div>
                                  </div>

                                  <div class="stamp">
                                    <div class="stamp-circle">ختم رسمي</div>
                                  </div>

                                  <div class="footer">
                                    <div class="notice">* يجب عرض هذا الترخيص في مكان ظاهر داخل المنشأة</div>
                                    <div class="notice">* هذا الترخيص صالح فقط خلال الفترة المحددة أعلاه</div>
                                  </div>
                                </body>
                                </html>
                                """
                                .formatted(
                                                license.getLicenseNumber(),
                                                license.getLicenseNumber(),
                                                issueStr,
                                                expiryStr,
                                                app.getLicenseType(),
                                                facility.getNameAr(),
                                                facilityTypeAr,
                                                facility.getDistrict() != null ? facility.getDistrict() : "",
                                                (facility.getArea() != null ? facility.getArea() : "") + " - " +
                                                                (facility.getStreet() != null ? facility.getStreet()
                                                                                : ""),
                                                app.getApplicationNumber(),
                                                app.getSupervisorName() != null ? app.getSupervisorName() : "",
                                                app.getSupervisorNationalId() != null ? app.getSupervisorNationalId()
                                                                : "",
                                                app.getSupervisorQualification() != null
                                                                ? app.getSupervisorQualification()
                                                                : "",
                                                app.getSupervisorPracticeLicense() != null
                                                                ? app.getSupervisorPracticeLicense()
                                                                : "",
                                                fee,
                                                verifyUrl);

                // Save to file system
                String fileName = "LICENSE_" + license.getLicenseNumber().replace("-", "_") + ".html";
                try {
                        Path uploadDir = Paths.get("uploads").toAbsolutePath().normalize();
                        Files.createDirectories(uploadDir);
                        Files.writeString(uploadDir.resolve(fileName), html);
                } catch (IOException e) {
                        throw new RuntimeException("Failed to write license file: " + e.getMessage(), e);
                }

                return fileName;
        }

        private String mapFacilityTypeAr(String type) {
                return switch (type) {
                        case "HOSPITAL" -> "مستشفى";
                        case "CENTER" -> "مركز طبي";
                        case "CLINIC" -> "عيادة";
                        case "DENTAL_CLINIC" -> "عيادة أسنان";
                        case "EMERGENCY_CLINIC" -> "عيادة إسعافية";
                        case "LABORATORY" -> "مختبر";
                        case "RADIOLOGY_LAB" -> "مختبر أشعة";
                        case "PHARMACY" -> "صيدلية";
                        default -> type;
                };
        }

        private LicenseDto toDto(License l) {
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
}
