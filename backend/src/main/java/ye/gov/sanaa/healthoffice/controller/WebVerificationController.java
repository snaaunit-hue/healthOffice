package ye.gov.sanaa.healthoffice.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import ye.gov.sanaa.healthoffice.dto.PublicLicenseDto;
import ye.gov.sanaa.healthoffice.service.LicenseService;
import java.time.format.DateTimeFormatter;

@RestController
@RequestMapping("/public/verify")
@RequiredArgsConstructor
public class WebVerificationController {

    private final LicenseService licenseService;
    private static final DateTimeFormatter AR_DATE_FMT = DateTimeFormatter.ofPattern("yyyy/MM/dd");

    @GetMapping(value = "/{licenseNumber}", produces = MediaType.TEXT_HTML_VALUE)
    public ResponseEntity<String> verifyPage(@PathVariable String licenseNumber) {
        try {
            PublicLicenseDto dto = licenseService.verifyLicense(licenseNumber);
            String html = generateHtml(dto);
            return ResponseEntity.ok(html);
        } catch (RuntimeException e) {
            return ResponseEntity.ok(generateErrorHtml(licenseNumber));
        }
    }

    private String generateHtml(PublicLicenseDto dto) {
        String statusColor = Boolean.TRUE.equals(dto.getIsValid()) ? "#388E3C" : "#D32F2F";
        String statusIcon = Boolean.TRUE.equals(dto.getIsValid()) ? "✓" : "✕";
        String statusText = Boolean.TRUE.equals(dto.getIsValid()) ? "ترخيص ساري المفعول" : "الترخيص غير صالح";
        String rawStatus = dto.getStatus();
        if ("REVOKED".equals(rawStatus)) {
            statusText = "الترخيص ملغى";
            statusColor = "#D32F2F";
        } else if ("EXPIRED".equals(rawStatus)) {
            statusText = "الترخيص منتهي";
            statusColor = "#FF8F00";
        }

        return """
                    <!DOCTYPE html>
                    <html dir="rtl" lang="ar">
                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>تحقق من الترخيص - %s</title>
                        <style>
                            :root { --primary: #0D6B3F; --surface: #f8f9fa; --card-bg: #ffffff; }
                            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: var(--surface); color: #333; margin: 0; padding: 20px; display: flex; justify-content: center; align-items: center; min-height: 100vh; }
                            .card { background: var(--card-bg); border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); width: 100%%; max-width: 400px; overflow: hidden; animation: slideUp 0.6s ease-out; }
                            .header { background: var(--primary); color: white; padding: 24px; text-align: center; position: relative; }
                            .logo { font-size: 2rem; margin-bottom: 8px; }
                            .title { font-size: 1.1rem; opacity: 0.9; }
                            .status-badge { background: %s; color: white; width: 80px; height: 80px; border-radius: 50%%; display: flex; align-items: center; justify-content: center; font-size: 2rem; position: absolute; bottom: -40px; left: 50%%; transform: translateX(-50%%); box-shadow: 0 4px 10px rgba(0,0,0,0.2); animation: popIn 0.5s 0.3s backwards; }
                            .content { padding: 50px 24px 24px; text-align: center; }
                            .license-status { font-size: 1.25rem; font-weight: bold; color: %s; margin-bottom: 24px; }
                            .detail-row { display: flex; justify-content: space-between; padding: 12px 0; border-bottom: 1px solid #eee; }
                            .detail-row:last-child { border-bottom: none; }
                            .label { color: #666; font-size: 0.9rem; }
                            .value { font-weight: 600; font-size: 0.95rem; }
                            .footer { background: #f1f3f5; padding: 12px; text-align: center; font-size: 0.8rem; color: #888; }

                            @keyframes slideUp { from { opacity: 0; transform: translateY(20px); } to { opacity: 1; transform: translateY(0); } }
                            @keyframes popIn { from { transform: translateX(-50%%) scale(0); } to { transform: translateX(-50%%) scale(1); } }
                        </style>
                    </head>
                    <body>
                        <div class="card">
                            <div class="header">
                                <div class="logo">🏛️</div>
                                <div class="title">مكتب الصحة والبيئة - أمانة العاصمة</div>
                                <div class="status-badge">%s</div>
                            </div>
                            <div class="content">
                                <div class="license-status">%s</div>

                                <div class="detail-row">
                                    <span class="label">رقم الترخيص</span>
                                    <span class="value">%s</span>
                                </div>
                                <div class="detail-row">
                                    <span class="label">المنشأة</span>
                                    <span class="value">%s</span>
                                </div>
                                <div class="detail-row">
                                    <span class="label">النوع</span>
                                    <span class="value">%s</span>
                                </div>
                                <div class="detail-row">
                                    <span class="label">تاريخ الانتهاء</span>
                                    <span class="value">%s</span>
                                </div>
                                <div class="detail-row">
                                    <span class="label">المشرف الفني</span>
                                    <span class="value">%s</span>
                                </div>
                            </div>
                            <div class="footer">
                                تم التحقق من صحة البيانات إلكترونياً
                                <br>
                                %s
                            </div>
                        </div>
                    </body>
                    </html>
                """
                .formatted(
                        dto.getLicenseNumber(),
                        statusColor, statusColor,
                        statusIcon,
                        statusText,
                        dto.getLicenseNumber(),
                        dto.getFacilityName() != null ? dto.getFacilityName() : "-",
                        dto.getFacilityType() != null ? dto.getFacilityType() : "-",
                        dto.getExpiryDate() != null ? dto.getExpiryDate().format(AR_DATE_FMT) : "-",
                        dto.getSupervisorName() != null ? dto.getSupervisorName() : "-",
                        java.time.LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm")));
    }

    private String generateErrorHtml(String licenseNumber) {
        return """
                    <!DOCTYPE html>
                    <html dir="rtl" lang="ar">
                    <head>
                        <meta charset="UTF-8">
                        <meta name="viewport" content="width=device-width, initial-scale=1.0">
                        <title>خطأ في التحقق</title>
                        <style>
                            body { font-family: system-ui, sans-serif; background: #f8f9fa; display: flex; justify-content: center; align-items: center; min-height: 100vh; margin: 0; }
                            .card { background: white; padding: 40px; border-radius: 16px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); text-align: center; max-width: 90%%; width: 350px; }
                            .icon { font-size: 4rem; color: #D32F2F; margin-bottom: 16px; }
                            h2 { margin: 0 0 8px; color: #333; }
                            p { color: #666; margin: 0; }
                        </style>
                    </head>
                    <body>
                        <div class="card">
                            <div class="icon">⚠️</div>
                            <h2>رقم الترخيص غير موجود</h2>
                            <p>لم يتم العثور على ترخيص برقم: <strong>%s</strong></p>
                            <p>يرجى التأكد من صحة الرمز أو مراجعة المكتب.</p>
                        </div>
                    </body>
                    </html>
                """
                .formatted(licenseNumber);
    }
}
