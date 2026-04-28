package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.BusinessLicenseDTO;
import bitc.next502.next502_backend.service.OcrService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@Slf4j
@RestController
@RequestMapping("/ocr")
@RequiredArgsConstructor
public class OcrController {

    private final OcrService ocrService;

    /**
     * 사업자등록증 이미지를 분석하여 상호/번호/대표자/주소를 추출.

     */
    @PostMapping("/business-license")
    public ResponseEntity<?> extractBusinessLicense(@RequestParam("file") MultipartFile file) {
        if (file.isEmpty()) {
            return ResponseEntity.badRequest().body("파일이 비어 있습니다.");
        }
        if (file.getSize() > 10L * 1024 * 1024) {
            return ResponseEntity.badRequest().body("파일 크기가 10MB를 초과합니다.");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            return ResponseEntity.badRequest().body("이미지 파일만 업로드 가능합니다.");
        }

        try {
            BusinessLicenseDTO result = ocrService.extractBusinessLicense(file);
            return ResponseEntity.ok(result);
        }
        catch (Exception e) {
            log.error("[OCR] 사업자등록증 분석 실패", e);
            return ResponseEntity.internalServerError()
                    .body("OCR 분석 중 오류 발생: " + e.getMessage());
        }
    }
}