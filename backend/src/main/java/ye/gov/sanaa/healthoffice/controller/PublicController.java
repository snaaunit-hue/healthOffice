package ye.gov.sanaa.healthoffice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import ye.gov.sanaa.healthoffice.entity.SystemSetting;
import ye.gov.sanaa.healthoffice.repository.SystemSettingRepository;

import java.util.*;
import java.util.stream.Collectors;
import ye.gov.sanaa.healthoffice.entity.Complaint;
import ye.gov.sanaa.healthoffice.repository.ComplaintRepository;
import ye.gov.sanaa.healthoffice.repository.PublicContentRepository;
import ye.gov.sanaa.healthoffice.entity.PublicContent;

@RestController
@RequestMapping("/api/v1/public")
@RequiredArgsConstructor
public class PublicController {

        private final SystemSettingRepository systemSettingRepository;
        private final ye.gov.sanaa.healthoffice.repository.LicenseRepository licenseRepository;
        private final ye.gov.sanaa.healthoffice.service.LicenseService licenseService;
        private final PublicContentRepository publicContentRepository;
        private final ComplaintRepository complaintRepository;

        @GetMapping("/verify/{licenseNumber}")
        public ResponseEntity<ye.gov.sanaa.healthoffice.dto.PublicLicenseDto> verifyLicense(
                        @PathVariable String licenseNumber) {
                try {
                        return ResponseEntity.ok(licenseService.verifyLicense(licenseNumber));
                } catch (RuntimeException e) {
                        return ResponseEntity.notFound().build();
                }
        }

        @GetMapping("/license-check")
        public ResponseEntity<ye.gov.sanaa.healthoffice.dto.PublicLicenseDto> checkLicense(
                        @RequestParam String licenseNumber) {
                var licenseOpt = licenseRepository.findByLicenseNumber(licenseNumber);
                if (licenseOpt.isEmpty()) {
                        return ResponseEntity.notFound().build();
                }
                var license = licenseOpt.get();
                boolean isValid = "ACTIVE".equals(license.getStatus())
                                && license.getExpiryDate().isAfter(java.time.LocalDate.now());

                var dto = ye.gov.sanaa.healthoffice.dto.PublicLicenseDto.builder()
                                .facilityName(license.getApplication().getFacility().getNameAr())
                                .licenseNumber(license.getLicenseNumber())
                                .facilityType(license.getApplication().getFacility().getFacilityType())
                                .status(license.getStatus())
                                .expiryDate(license.getExpiryDate())
                                .isValid(isValid)
                                .build();
                return ResponseEntity.ok(dto);
        }

        @GetMapping("/services")
        public ResponseEntity<List<Map<String, String>>> getServices() {
                List<SystemSetting> services = systemSettingRepository.findByCategory("SERVICES");
                List<Map<String, String>> result = services.stream()
                                .map(s -> Map.of("key", s.getSettingKey(), "value", s.getSettingValue(), "description",
                                                s.getDescription() != null ? s.getDescription() : ""))
                                .collect(Collectors.toList());
                return ResponseEntity.ok(result);
        }

        @GetMapping("/requirements")
        public ResponseEntity<List<Map<String, String>>> getRequirements() {
                List<SystemSetting> reqs = systemSettingRepository.findByCategory("REQUIREMENTS");
                List<Map<String, String>> result = reqs.stream()
                                .map(s -> Map.of("key", s.getSettingKey(), "value", s.getSettingValue()))
                                .collect(Collectors.toList());
                return ResponseEntity.ok(result);
        }

        @GetMapping("/about")
        public ResponseEntity<Map<String, String>> getAbout() {
                var aboutAr = systemSettingRepository.findByCategoryAndSettingKey("CONTENT", "ABOUT_AR");
                var aboutEn = systemSettingRepository.findByCategoryAndSettingKey("CONTENT", "ABOUT_EN");
                return ResponseEntity.ok(Map.of(
                                "aboutAr", aboutAr.map(SystemSetting::getSettingValue).orElse(""),
                                "aboutEn", aboutEn.map(SystemSetting::getSettingValue).orElse("")));
        }

        @GetMapping("/news")
        public ResponseEntity<List<Map<String, String>>> getNews() {
                List<SystemSetting> news = systemSettingRepository.findByCategory("NEWS");
                List<Map<String, String>> result = news.stream()
                                .map(s -> Map.of("key", s.getSettingKey(), "value", s.getSettingValue()))
                                .collect(Collectors.toList());
                return ResponseEntity.ok(result);
        }

        @GetMapping("/contact")
        public ResponseEntity<Map<String, String>> getContact() {
                var phone = systemSettingRepository.findByCategoryAndSettingKey("CONTACT", "PHONE");
                var email = systemSettingRepository.findByCategoryAndSettingKey("CONTACT", "EMAIL");
                var address = systemSettingRepository.findByCategoryAndSettingKey("CONTACT", "ADDRESS");
                return ResponseEntity.ok(Map.of(
                                "phone", phone.map(SystemSetting::getSettingValue).orElse(""),
                                "email", email.map(SystemSetting::getSettingValue).orElse(""),
                                "address", address.map(SystemSetting::getSettingValue).orElse("")));
        }

        @GetMapping("/content/{category}")
        public ResponseEntity<List<PublicContent>> getContent(@PathVariable String category) {
                return ResponseEntity.ok(
                                publicContentRepository.findByCategoryAndIsPublishedTrueOrderByCreatedAtDesc(category));
        }

        @PostMapping("/complaints")
        public ResponseEntity<Void> submitComplaint(@RequestBody Complaint complaint) {
                complaintRepository.save(complaint);
                return ResponseEntity.ok().build();
        }
}
