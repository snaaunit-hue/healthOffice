package ye.gov.sanaa.healthoffice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ye.gov.sanaa.healthoffice.dto.*;
import ye.gov.sanaa.healthoffice.service.*;

import java.util.List;

@RestController
@RequestMapping("/api/v1/portal")
@RequiredArgsConstructor
public class PortalController {

    private final ApplicationService applicationService;
    private final NotificationService notificationService;
    private final PaymentService paymentService;

    @PostMapping("/applications")
    public ResponseEntity<ApplicationDto> createDraft(
            @RequestParam Long facilityId,
            @RequestParam Long userId,
            @RequestBody ApplicationDto dto) {
        return ResponseEntity.ok(applicationService.createDraft(facilityId, userId, dto));
    }

    @PostMapping("/applications/{id}/submit")
    public ResponseEntity<ApplicationDto> submitApplication(
            @PathVariable Long id,
            @RequestParam Long userId) {
        return ResponseEntity.ok(applicationService.submitApplication(id, userId));
    }

    @GetMapping("/applications")
    public ResponseEntity<Page<ApplicationDto>> getMyApplications(
            @RequestParam Long facilityId,
            Pageable pageable) {
        return ResponseEntity.ok(applicationService.getByFacility(facilityId, pageable));
    }

    @GetMapping("/applications/{id}")
    public ResponseEntity<ApplicationDto> getApplication(@PathVariable Long id) {
        return ResponseEntity.ok(applicationService.getById(id));
    }

    @GetMapping("/applications/{id}/steps")
    public ResponseEntity<List<ApplicationStepDto>> getSteps(@PathVariable Long id) {
        return ResponseEntity.ok(applicationService.getSteps(id));
    }

    @GetMapping("/applications/{id}/documents")
    public ResponseEntity<List<ApplicationDocumentDto>> getDocuments(@PathVariable Long id) {
        return ResponseEntity.ok(applicationService.getDocuments(id));
    }

    @PostMapping("/applications/{id}/documents")
    public ResponseEntity<ApplicationDocumentDto> addDocument(
            @PathVariable Long id,
            @RequestParam Long userId,
            @RequestBody ApplicationDocumentDto dto) {
        return ResponseEntity.ok(applicationService.addDocument(id, userId, dto));
    }

    @GetMapping("/applications/{id}/payments")
    public ResponseEntity<List<PaymentDto>> getPayments(@PathVariable Long id) {
        return ResponseEntity.ok(paymentService.getByApplication(id));
    }

    @GetMapping("/notifications")
    public ResponseEntity<Page<NotificationDto>> getNotifications(
            @RequestParam Long userId,
            Pageable pageable) {
        return ResponseEntity.ok(notificationService.getUserNotifications(userId, pageable));
    }

    @GetMapping("/notifications/unread-count")
    public ResponseEntity<Long> getUnreadCount(@RequestParam Long userId) {
        return ResponseEntity.ok(notificationService.getUnreadCount(userId, false));
    }

    @PutMapping("/notifications/{id}/read")
    public ResponseEntity<Void> markAsRead(@PathVariable Long id) {
        notificationService.markAsRead(id);
        return ResponseEntity.ok().build();
    }
}
