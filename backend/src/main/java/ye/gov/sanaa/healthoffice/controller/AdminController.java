package ye.gov.sanaa.healthoffice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ye.gov.sanaa.healthoffice.dto.*;
import ye.gov.sanaa.healthoffice.service.*;

import java.time.OffsetDateTime;
import java.util.Map;

@RestController
@RequestMapping("/api/v1/admin")
@RequiredArgsConstructor
public class AdminController {

    private final ApplicationService applicationService;
    private final InspectionService inspectionService;
    private final PaymentService paymentService;
    private final NotificationService notificationService;
    private final DashboardService dashboardService;
    private final LicenseService licenseService;
    private final AdminService adminService;
    private final FacilityService facilityService;

    // ===== Dashboard =====
    @GetMapping("/dashboard/stats")
    public ResponseEntity<DashboardStatsDto> getDashboardStats() {
        return ResponseEntity.ok(dashboardService.getStats());
    }

    // ===== Licenses =====
    @GetMapping("/licenses")
    public ResponseEntity<Page<LicenseDto>> getAllLicenses(Pageable pageable) {
        return ResponseEntity.ok(applicationService.getAllLicenses(pageable));
    }

    // ===== Violations =====
    @GetMapping("/violations")
    public ResponseEntity<Page<ViolationDto>> getAllViolations(Pageable pageable) {
        return ResponseEntity.ok(applicationService.getAllViolations(pageable));
    }

    // ===== Payments List =====
    @GetMapping("/payments")
    public ResponseEntity<Page<PaymentDto>> getAllPayments(Pageable pageable) {
        return ResponseEntity.ok(paymentService.getAll(pageable));
    }

    // ===== Applications =====
    @GetMapping("/applications")
    public ResponseEntity<Page<ApplicationDto>> getAllApplications(Pageable pageable) {
        return ResponseEntity.ok(applicationService.getAll(pageable));
    }

    @GetMapping("/applications/by-status")
    public ResponseEntity<Page<ApplicationDto>> getByStatus(
            @RequestParam String status, Pageable pageable) {
        return ResponseEntity.ok(applicationService.getByStatus(status, pageable));
    }

    @GetMapping("/applications/{id}")
    public ResponseEntity<ApplicationDto> getApplication(@PathVariable Long id) {
        return ResponseEntity.ok(applicationService.getById(id));
    }

    @PostMapping("/applications/{id}/advance")
    public ResponseEntity<ApplicationDto> advanceWorkflow(
            @PathVariable Long id,
            @RequestParam Long adminId,
            @RequestBody(required = false) Map<String, String> body) {
        String notes = body != null ? body.getOrDefault("notes", "") : "";
        return ResponseEntity.ok(applicationService.advanceWorkflow(id, adminId, notes));
    }

    @PostMapping("/applications/{id}/reject")
    public ResponseEntity<ApplicationDto> rejectApplication(
            @PathVariable Long id,
            @RequestParam Long adminId,
            @RequestBody Map<String, String> body) {
        return ResponseEntity.ok(applicationService.rejectApplication(id, adminId, body.get("reason")));
    }

    // ===== Inspections =====
    @PostMapping("/inspections/schedule")
    public ResponseEntity<InspectionDto> scheduleInspection(
            @RequestParam Long applicationId,
            @RequestParam Long inspectorId,
            @RequestParam String scheduledDate) {
        return ResponseEntity.ok(inspectionService.scheduleInspection(
                applicationId, inspectorId, OffsetDateTime.parse(scheduledDate)));
    }

    @PostMapping("/inspections/{id}/complete")
    public ResponseEntity<InspectionDto> completeInspection(
            @PathVariable Long id,
            @RequestBody InspectionDto dto) {
        return ResponseEntity.ok(inspectionService.completeInspection(id, dto));
    }

    @GetMapping("/inspections")
    public ResponseEntity<Page<InspectionDto>> getInspections(
            @RequestParam(required = false) String status,
            @RequestParam(required = false) Long inspectorId,
            Pageable pageable) {
        if (inspectorId != null) {
            return ResponseEntity.ok(inspectionService.getByInspector(inspectorId, pageable));
        }
        if (status != null) {
            return ResponseEntity.ok(inspectionService.getByStatus(status, pageable));
        }
        return ResponseEntity.ok(inspectionService.getByStatus("SCHEDULED", pageable));
    }

    @GetMapping("/inspections/active-by-application/{applicationId}")
    public ResponseEntity<InspectionDto> getActiveByApplication(@PathVariable Long applicationId) {
        return ResponseEntity.ok(inspectionService.getActiveForApplication(applicationId));
    }

    @GetMapping("/inspections/{id}")
    public ResponseEntity<InspectionDto> getInspection(@PathVariable Long id) {
        return ResponseEntity.ok(inspectionService.getById(id));
    }

    @GetMapping("/users/inspectors")
    public ResponseEntity<java.util.List<AdminDto>> getInspectors() {
        return ResponseEntity.ok(inspectionService.getInspectors());
    }

    // ===== Payments =====
    @PostMapping("/payments/create")
    public ResponseEntity<PaymentDto> createPayment(
            @RequestParam Long applicationId,
            @RequestParam Long adminId) {
        return ResponseEntity.ok(paymentService.createPaymentOrder(applicationId, adminId));
    }

    @PostMapping("/payments/confirm")
    public ResponseEntity<PaymentDto> confirmPayment(@RequestBody Map<String, String> body) {
        return ResponseEntity.ok(paymentService.confirmPayment(
                body.get("paymentReference"),
                body.get("channel"),
                body.get("externalTransactionId")));
    }

    @GetMapping("/payments/by-application/{applicationId}")
    public ResponseEntity<java.util.List<PaymentDto>> getPaymentByApplication(@PathVariable Long applicationId) {
        return ResponseEntity.ok(paymentService.getByApplication(applicationId));
    }

    // ===== Notifications =====
    @GetMapping("/notifications")
    public ResponseEntity<Page<NotificationDto>> getNotifications(
            @RequestParam Long adminId, Pageable pageable) {
        return ResponseEntity.ok(notificationService.getAdminNotifications(adminId, pageable));
    }

    @GetMapping("/notifications/unread-count")
    public ResponseEntity<Long> getUnreadCount(@RequestParam Long adminId) {
        return ResponseEntity.ok(notificationService.getUnreadCount(adminId, true));
    }

    @PutMapping("/notifications/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok().build();
    }

    // ===== License Management =====

    @PostMapping("/licenses/generate")
    public ResponseEntity<LicenseDto> generateLicensePdf(
            @RequestParam Long applicationId,
            @RequestParam Long adminId) {
        return ResponseEntity.ok(licenseService.generateLicensePdf(applicationId, adminId));
    }

    @PostMapping("/licenses/{id}/reprint")
    public ResponseEntity<LicenseDto> reprintLicense(
            @PathVariable Long id,
            @RequestParam Long adminId) {
        return ResponseEntity.ok(licenseService.reprintLicense(id, adminId));
    }

    @PostMapping("/licenses/{id}/invalidate")
    public ResponseEntity<LicenseDto> invalidateLicense(
            @PathVariable Long id,
            @RequestParam Long adminId,
            @RequestBody Map<String, String> body) {
        String reason = body.getOrDefault("reason", "");
        return ResponseEntity.ok(licenseService.invalidateLicense(id, adminId, reason));
    }

    @PutMapping("/licenses/{id}/update-dates")
    public ResponseEntity<LicenseDto> updateLicenseDates(
            @PathVariable Long id,
            @RequestParam Long adminId,
            @RequestParam String issueDate,
            @RequestParam String expiryDate) {
        return ResponseEntity.ok(licenseService.updateLicenseDates(id, adminId,
                java.time.LocalDate.parse(issueDate),
                java.time.LocalDate.parse(expiryDate)));
    }

    @GetMapping("/licenses/by-application/{appId}")
    public ResponseEntity<LicenseDto> getLicenseByApplication(@PathVariable Long appId) {
        return ResponseEntity.ok(licenseService.getByApplication(appId));
    }

    // ===== Employee Management =====

    @PostMapping("/employees")
    public ResponseEntity<AdminDto> createEmployee(@RequestBody CreateEmployeeDto dto) {
        return ResponseEntity.ok(adminService.createEmployee(dto));
    }

    @PutMapping("/employees/{id}")
    public ResponseEntity<AdminDto> updateEmployee(@PathVariable Long id, @RequestBody UpdateEmployeeDto dto) {
        return ResponseEntity.ok(adminService.updateEmployee(id, dto));
    }

    @DeleteMapping("/employees/{id}")
    public ResponseEntity<Void> deleteEmployee(@PathVariable Long id) {
        adminService.deleteEmployee(id);
        return ResponseEntity.ok().build();
    }

    @GetMapping("/employees")
    public ResponseEntity<Page<AdminDto>> getAllEmployees(Pageable pageable) {
        return ResponseEntity.ok(adminService.getAllEmployees(pageable));
    }

    @GetMapping("/employees/{id}")
    public ResponseEntity<AdminDto> getEmployee(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.getEmployee(id));
    }

    // ===== Facilities (filter, operational status) =====
    @GetMapping("/facilities")
    public ResponseEntity<Page<FacilityDto>> getFacilities(
            @RequestParam(required = false) String facilityType,
            @RequestParam(required = false) String governorate,
            @RequestParam(required = false) String district,
            @RequestParam(required = false) String operationalStatus,
            Pageable pageable) {
        return ResponseEntity.ok(facilityService.getAllFiltered(
                facilityType, governorate, district, operationalStatus, pageable));
    }

    @PutMapping("/facilities/{id}/operational-status")
    public ResponseEntity<FacilityDto> updateFacilityOperationalStatus(
            @PathVariable Long id,
            @RequestParam Long adminId,
            @RequestParam String operationalStatus) {
        return ResponseEntity.ok(facilityService.updateOperationalStatus(id, operationalStatus, adminId));
    }

    // ===== Facility User Management =====

    @GetMapping("/facility-users")
    public ResponseEntity<Page<FacilityUserDto>> getAllFacilityUsers(Pageable pageable) {
        return ResponseEntity.ok(adminService.getAllFacilityUsers(pageable));
    }

    @PostMapping("/facility-users/{id}/toggle-status")
    public ResponseEntity<FacilityUserDto> toggleUserStatus(@PathVariable Long id) {
        return ResponseEntity.ok(adminService.toggleUserStatus(id));
    }
}
