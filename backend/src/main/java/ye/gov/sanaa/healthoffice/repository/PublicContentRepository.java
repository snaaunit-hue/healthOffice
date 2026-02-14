package ye.gov.sanaa.healthoffice.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ye.gov.sanaa.healthoffice.entity.PublicContent;
import java.util.List;

public interface PublicContentRepository extends JpaRepository<PublicContent, Long> {
    List<PublicContent> findByCategoryAndIsPublishedTrueOrderByCreatedAtDesc(String category);

    List<PublicContent> findByIsPublishedTrueOrderByCreatedAtDesc();
}
