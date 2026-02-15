package ye.gov.sanaa.healthoffice.repository.spec;

import org.springframework.data.jpa.domain.Specification;
import org.springframework.util.StringUtils;
import ye.gov.sanaa.healthoffice.entity.Facility;

public class FacilitySpecification {

    public static Specification<Facility> filterBy(
            String search,
            String governorate,
            String district,
            String facilityType,
            String operationalStatus,
            String sector
    ) {
        return (root, query, cb) -> {
            Specification<Facility> spec = Specification.where(null);

            if (StringUtils.hasText(search)) {
                String pattern = "%" + search.toLowerCase() + "%";
                spec = spec.and((root2, query2, cb2) ->
                        cb2.or(
                                cb2.like(cb2.lower(root2.get("nameAr")), pattern),
                                cb2.like(cb2.lower(root2.get("nameEn")), pattern),
                                cb2.like(cb2.lower(root2.get("facilityCode")), pattern)
                        )
                );
            }

            if (StringUtils.hasText(governorate)) {
                spec = spec.and((root2, query2, cb2) ->
                        cb2.equal(root2.get("governorate"), governorate)
                );
            }

            if (StringUtils.hasText(district)) {
                spec = spec.and((root2, query2, cb2) ->
                        cb2.equal(root2.get("district"), district)
                );
            }

            if (StringUtils.hasText(facilityType)) {
                spec = spec.and((root2, query2, cb2) ->
                        cb2.equal(root2.get("facilityType"), facilityType)
                );
            }

            if (StringUtils.hasText(operationalStatus)) {
                spec = spec.and((root2, query2, cb2) ->
                        cb2.equal(root2.get("operationalStatus"), operationalStatus)
                );
            }

            if (StringUtils.hasText(sector)) {
                spec = spec.and((root2, query2, cb2) ->
                        cb2.equal(root2.get("sector"), sector)
                );
            }

            return spec.toPredicate(root, query, cb);
        };
    }
}
