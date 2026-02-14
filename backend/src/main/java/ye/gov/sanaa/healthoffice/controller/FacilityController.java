package ye.gov.sanaa.healthoffice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ye.gov.sanaa.healthoffice.dto.FacilityDto;
import ye.gov.sanaa.healthoffice.service.FacilityService;

@RestController
@RequestMapping("/api/facilities")
@RequiredArgsConstructor
public class FacilityController {

    private final FacilityService facilityService;

    @PostMapping
    public ResponseEntity<FacilityDto> createFacility(@RequestBody FacilityDto dto) {
        return ResponseEntity.ok(facilityService.createFacility(dto));
    }

    @PutMapping("/{id}/location")
    public ResponseEntity<FacilityDto> updateLocation(
            @PathVariable Long id,
            @RequestParam Double latitude,
            @RequestParam Double longitude) {
        return ResponseEntity.ok(facilityService.updateLocation(id, latitude, longitude));
    }

    @GetMapping
    public ResponseEntity<Page<FacilityDto>> getAll(Pageable pageable) {
        return ResponseEntity.ok(facilityService.getAll(pageable));
    }

    @GetMapping("/{id}")
    public ResponseEntity<FacilityDto> getById(@PathVariable Long id) {
        return ResponseEntity.ok(facilityService.getById(id));
    }
}
