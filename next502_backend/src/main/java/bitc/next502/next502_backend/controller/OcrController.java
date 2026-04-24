package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.service.OcrService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequiredArgsConstructor
@CrossOrigin(origins = "http://localhost:5173")
public class OcrController {

    private final OcrService ocrService;

    @PostMapping("/ocr/verify-name")
    public ResponseEntity<?> uploadAndExtractName(@RequestParam("file") MultipartFile file) throws Exception {
        // 1. 임시 파일 생성
        File tempFile = File.createTempFile("ocr_", file.getOriginalFilename());
        file.transferTo(tempFile);

        try {
            // 2. OCR 실행하여 전체 텍스트 추출
            String fullText = ocrService.getOcrText(tempFile);

            // 3. 서비스에 만든 extractName 메서드로 이름만 추출
            String extractedName = ocrService.extractName(fullText);

            // 4. 결과를 JSON 형태로 반환 (리액트에서 받기 편함)
            Map<String, String> response = new HashMap<>();
            response.put("extractedName", extractedName);
            // response.put("fullText", fullText); // 디버깅용으로 필요하면 포함

            return ResponseEntity.ok(response);

        } finally {
            // 5. 에러가 나더라도 임시 파일은 반드시 삭제
            if (tempFile.exists()) {
                tempFile.delete();
            }
        }
    }
}

