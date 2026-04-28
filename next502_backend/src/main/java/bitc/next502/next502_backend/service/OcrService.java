package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.config.clova.ClovaOcrProperties;
import bitc.next502.next502_backend.domain.dto.BusinessLicenseDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.MediaType;
import org.springframework.http.client.MultipartBodyBuilder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.reactive.function.BodyInserters;
import org.springframework.web.reactive.function.client.WebClient;

import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
public class OcrService {

    private final ClovaOcrProperties clovaProps;
    private final ObjectMapper objectMapper = new ObjectMapper();


    public BusinessLicenseDTO extractBusinessLicense(MultipartFile file) throws Exception {
        // mock 모드: NCP 키 발급 전 개발용 더미 응답
        if (clovaProps.isMock()
                || clovaProps.getInvokeUrl() == null
                || clovaProps.getInvokeUrl().isBlank()) {
            log.warn("[OCR] mock 모드 동작 중 - 실제 CLOVA 호출 안 함");
            return mockResponse();
        }

        String originalName = (file.getOriginalFilename() != null)
                ? file.getOriginalFilename() : "biz.jpg";
        String ext = extractExtension(originalName);


        String messageJson = """
        {
          "version": "V2",
          "requestId": "%s",
          "timestamp": %d,
          "images": [
            { "format": "%s", "name": "biz_license" }
          ]
        }
        """.formatted(UUID.randomUUID().toString(), System.currentTimeMillis(), ext);

        // multipart/form-data 구성
        MultipartBodyBuilder builder = new MultipartBodyBuilder();
        builder.part("message", messageJson, MediaType.APPLICATION_JSON);
        builder.part("file", new ByteArrayResource(file.getBytes()) {
            @Override
            public String getFilename() {
                return originalName;
            }
        }).contentType(MediaType.parseMediaType(
                file.getContentType() != null ? file.getContentType() : "image/jpeg"));

        WebClient webClient = WebClient.builder()
                .baseUrl(clovaProps.getInvokeUrl())
                .defaultHeader("X-OCR-SECRET", clovaProps.getSecretKey())
                .build();

        String responseBody = webClient.post()
                .contentType(MediaType.MULTIPART_FORM_DATA)
                .body(BodyInserters.fromMultipartData(builder.build()))
                .retrieve()
                .bodyToMono(String.class)
                .block();

        log.debug("[OCR] CLOVA raw response: {}", responseBody);

        return parseResponse(responseBody);
    }

    /**
     * CLOVA "사업자등록증 특화 템플릿" 응답을 파싱.
     */
    private BusinessLicenseDTO parseResponse(String body) throws Exception {
        JsonNode root = objectMapper.readTree(body);
        JsonNode result = root.path("images").path(0).path("bizLicense").path("result");

        return BusinessLicenseDTO.builder()
                .companyName(extractText(result, "companyName"))
                .registerNumber(extractText(result, "registerNumber"))
                .representativeName(extractText(result, "repName"))
                .businessAddress(extractText(result, "bizAddress"))
                .message("OCR 분석 완료")
                .build();
    }


    private String extractText(JsonNode resultNode, String fieldName) {
        JsonNode arr = resultNode.path(fieldName);
        if (arr.isArray() && arr.size() > 0) {
            JsonNode first = arr.get(0);
            if (first.hasNonNull("text")) {
                return first.get("text").asText();
            }
            JsonNode formatted = first.path("formatted");
            if (formatted.hasNonNull("value")) {
                return formatted.get("value").asText();
            }
        }
        return null;
    }

    /** 파일 확장자 추출 */
    private String extractExtension(String filename) {
        int dot = filename.lastIndexOf('.');
        if (dot < 0 || dot == filename.length() - 1) {
            return "jpg";
        }
        return filename.substring(dot + 1).toLowerCase();
    }

    /** mock 응답 - 실제 키 없을 때 프론트엔드 개발 진행용 */
    private BusinessLicenseDTO mockResponse() {
        return BusinessLicenseDTO.builder()
                .companyName("(주)창고이음테스트")
                .registerNumber("123-45-67890")
                .representativeName("홍길동")
                .businessAddress("부산광역시 사하구 감천항로 123")
                .message("[MOCK] 실제 CLOVA 호출 없음 - application.yaml에서 clova.ocr.mock=false로 변경 필요")
                .build();
    }
}