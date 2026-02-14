package ye.gov.sanaa.healthoffice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ye.gov.sanaa.healthoffice.entity.Violation;
import ye.gov.sanaa.healthoffice.service.ViolationService;
import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/violations")
@RequiredArgsConstructor
public class ViolationController {

    private final ViolationService violationService;

    @GetMapping("/active")
    public ResponseEntity<List<Violation>> getActiveViolations() {
        return ResponseEntity.ok(violationService.getAllActive());
    }

    @PostMapping
    public ResponseEntity<Violation> recordViolation(@RequestBody Violation violation) {
        return ResponseEntity.ok(violationService.addViolation(violation));
    }
}
