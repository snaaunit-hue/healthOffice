package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import ye.gov.sanaa.healthoffice.entity.Application;
import ye.gov.sanaa.healthoffice.entity.FacilityUser;
import ye.gov.sanaa.healthoffice.entity.Violation;
import ye.gov.sanaa.healthoffice.repository.ApplicationRepository;
import ye.gov.sanaa.healthoffice.repository.FacilityUserRepository;
import ye.gov.sanaa.healthoffice.repository.ViolationRepository;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ViolationService {

    private final ViolationRepository violationRepository;
    private final NotificationService notificationService;
    private final ApplicationRepository applicationRepository;
    private final FacilityUserRepository facilityUserRepository;

    public Violation addViolation(Violation violation) {
        Violation saved = violationRepository.save(violation);

        // Notify the facility owner
        if (violation.getApplication() != null) {
            Application app = applicationRepository.findById(violation.getApplication().getId()).orElse(null);
            if (app != null && app.getFacility() != null) {
                List<FacilityUser> users = facilityUserRepository.findByFacilityId(app.getFacility().getId());
                for (FacilityUser user : users) {
                    notificationService.notifyUser(user.getId(),
                            "مخالفة جديدة: " + violation.getCode(),
                            "New Violation: " + violation.getCode(),
                            "تم تسجيل مخالفة ضد منشأتك: " + violation.getDescription() + ". الإجراء: "
                                    + violation.getPenalty(),
                            "A violation has been recorded: " + violation.getDescription() + ". Penalty: "
                                    + violation.getPenalty(),
                            "VIOLATION");
                }
            }
        }

        return saved;
    }

    public List<Violation> getAllActive() {
        return violationRepository.findByIsActiveTrue();
    }
}
