package bitc.next502.next502_backend.config.clova;

import lombok.Getter;
import lombok.Setter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Setter
@Component
@ConfigurationProperties(prefix = "clova.ocr")
public class ClovaOcrProperties {

    /** NCP CLOVA OCR Invoke URL (도메인별 고유) */
    private String invokeUrl;

    /** NCP CLOVA OCR Secret Key */
    private String secretKey;

    /** true면 실제 API 호출 없이 더미 응답 반환 (개발용) */
    private boolean mock = true;
}