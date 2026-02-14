package ye.gov.sanaa.healthoffice.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import ye.gov.sanaa.healthoffice.dto.PaymentDto;
import ye.gov.sanaa.healthoffice.entity.*;
import ye.gov.sanaa.healthoffice.repository.*;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PaymentService {

        private final PaymentRepository paymentRepository;
        private final ApplicationRepository applicationRepository;
        private final SystemSettingRepository systemSettingRepository;
        private final AuditService auditService;
        private final NotificationService notificationService;

        @Transactional
        public PaymentDto createPaymentOrder(Long applicationId, Long adminId) {
                Application app = applicationRepository.findById(applicationId)
                                .orElseThrow(() -> new RuntimeException("Application not found"));

                if (!"COMMITTEE_APPROVED".equals(app.getStatus()) && !"PAYMENT_PENDING".equals(app.getStatus())) {
                        throw new RuntimeException(
                                        "Payment can only be created after committee approval. Current status: "
                                                        + app.getStatus());
                }

                BigDecimal fee = systemSettingRepository
                                .findByCategoryAndSettingKey("FEES", "LICENSE_FEE_" + app.getFacilityType())
                                .map(s -> new BigDecimal(s.getSettingValue()))
                                .orElse(new BigDecimal("150000.00"));

                String paymentRef = "PAY-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();

                Payment payment = Payment.builder()
                                .application(app)
                                .paymentReference(paymentRef)
                                .governorateCode("SANA_A_CAPITAL")
                                .amount(fee)
                                .status("PENDING")
                                .build();
                payment = paymentRepository.save(payment);

                app.setStatus("PAYMENT_PENDING");
                applicationRepository.save(app);

                auditService.log(adminId, null, "CREATE_PAYMENT", "PAYMENT", payment.getId(),
                                "Payment order created: " + paymentRef + ", amount: " + fee);

                notificationService.notifyUser(app.getSubmittedByUser().getId(),
                                "إصدار أمر الدفع", "Payment Order Created",
                                "المبلغ: " + fee + " ر.ي. المرجع: " + paymentRef,
                                "Amount: " + fee + " YR. Ref: " + paymentRef, "INFO");

                return toDto(payment);
        }

        @Transactional
        public PaymentDto confirmPayment(String paymentReference, String channel, String externalTxId) {
                Payment payment = paymentRepository.findByPaymentReference(paymentReference)
                                .orElseThrow(() -> new RuntimeException("Payment not found"));

                if (!"PENDING".equals(payment.getStatus())) {
                        throw new RuntimeException("Payment already processed");
                }

                payment.setStatus("PAID");
                payment.setPaidAt(OffsetDateTime.now());
                payment.setPaymentChannel(channel);
                payment.setExternalTransactionId(externalTxId);
                paymentRepository.save(payment);

                Application app = payment.getApplication();
                app.setStatus("PAYMENT_COMPLETED");
                applicationRepository.save(app);

                auditService.log(null, null, "CONFIRM_PAYMENT", "PAYMENT", payment.getId(),
                                "Payment confirmed via " + channel);

                notificationService.notifyUser(app.getSubmittedByUser().getId(),
                                "تأكيد الدفع", "Payment Confirmed",
                                "تم استلام الدفع بنجاح", "Payment received successfully", "SUCCESS");

                return toDto(payment);
        }

        @Transactional(readOnly = true)
        public List<PaymentDto> getByApplication(Long applicationId) {
                return paymentRepository.findByApplicationId(applicationId)
                                .stream().map(this::toDto).collect(Collectors.toList());
        }

        @Transactional(readOnly = true)
        public Page<PaymentDto> getAll(Pageable pageable) {
                return paymentRepository.findAll(pageable).map(this::toDto);
        }

        private PaymentDto toDto(Payment p) {
                return PaymentDto.builder()
                                .id(p.getId())
                                .applicationId(p.getApplication().getId())
                                .applicationNumber(p.getApplication().getApplicationNumber())
                                .paymentReference(p.getPaymentReference())
                                .governorateCode(p.getGovernorateCode())
                                .amount(p.getAmount())
                                .status(p.getStatus())
                                .paidAt(p.getPaidAt())
                                .paymentChannel(p.getPaymentChannel())
                                .build();
        }
}
