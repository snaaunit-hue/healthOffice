package ye.gov.sanaa.healthoffice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ye.gov.sanaa.healthoffice.dto.MedicalProfessionalDto;
import ye.gov.sanaa.healthoffice.dto.StaffAssignmentDto;
import ye.gov.sanaa.healthoffice.service.MedicalProfessionalService;

import java.util.List;

@RestController
@RequestMapping("/api/professionals")
@RequiredArgsConstructor
public class MedicalProfessionalController {

    private final MedicalProfessionalService professionalService;

    @PostMapping
    public ResponseEntity<MedicalProfessionalDto> createProfessional(@RequestBody MedicalProfessionalDto dto) {
        return ResponseEntity.ok(professionalService.createProfessional(dto));
    }

    @GetMapping("/search")
    public ResponseEntity<List<MedicalProfessionalDto>> search(@RequestParam String query) {
        return ResponseEntity.ok(professionalService.searchProfessionals(query));
    }

    @PostMapping("/assign")
    public ResponseEntity<Void> assignStaffToFacility(@RequestBody StaffAssignmentDto dto) {
        professionalService.assignStaffToFacility(dto);
        return ResponseEntity.ok().build();
    }
}
