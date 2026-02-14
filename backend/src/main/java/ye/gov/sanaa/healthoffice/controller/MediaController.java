package ye.gov.sanaa.healthoffice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ye.gov.sanaa.healthoffice.entity.PublicContent;
import ye.gov.sanaa.healthoffice.repository.PublicContentRepository;
import java.util.List;

@RestController
@RequestMapping("/api/v1/admin/media")
@RequiredArgsConstructor
public class MediaController {

    private final PublicContentRepository publicContentRepository;

    @GetMapping("/content")
    public ResponseEntity<List<PublicContent>> getAllContent() {
        return ResponseEntity.ok(publicContentRepository.findAll());
    }

    @PostMapping("/content")
    public ResponseEntity<PublicContent> createContent(@RequestBody PublicContent content) {
        return ResponseEntity.ok(publicContentRepository.save(content));
    }

    @PutMapping("/content/{id}")
    public ResponseEntity<PublicContent> updateContent(@PathVariable Long id, @RequestBody PublicContent content) {
        content.setId(id);
        return ResponseEntity.ok(publicContentRepository.save(content));
    }

    @DeleteMapping("/content/{id}")
    public ResponseEntity<Void> deleteContent(@PathVariable Long id) {
        publicContentRepository.deleteById(id);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/content/{id}/toggle-publish")
    public ResponseEntity<PublicContent> togglePublish(@PathVariable Long id) {
        PublicContent content = publicContentRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Content not found"));
        content.setIsPublished(!content.getIsPublished());
        return ResponseEntity.ok(publicContentRepository.save(content));
    }
}
