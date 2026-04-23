package bitc.next502.next502_backend.service;

import net.sourceforge.tess4j.Tesseract;
import net.sourceforge.tess4j.TesseractException;
import org.springframework.stereotype.Service;
import java.io.File;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Service
public class OcrService {

    // 1. 이미지에서 전체 텍스트 추출
    public String getOcrText(File imageFile) {
        Tesseract tesseract = new Tesseract();
        tesseract.setDatapath("C:/Program Files/Tesseract-OCR/tessdata");
        tesseract.setLanguage("kor+eng");

        try {
            return tesseract.doOCR(imageFile);
        } catch (TesseractException e) {
            return "";
        }
    }

    // 2. 전체 텍스트에서 '이름'만 정규식으로 추출
    public String extractName(String fullText) {
        // 공백 및 줄바꿈 제거 (인식률 향상)
        String cleanText = fullText.replaceAll("\\s", "");

        // 정규식: '대표자' 혹은 '성명' 뒤에 오는 한글 2~4자 추출
        // 패턴 설명: (키워드)(기호 혹은 공백)(한글 2~4자)
        Pattern pattern = Pattern.compile("(대표자|성명|이름)[:\\s]?([가-힣]{2,4})");
        Matcher matcher = pattern.matcher(cleanText);

        if (matcher.find()) {
            return matcher.group(2); // 두 번째 괄호 내용(이름) 반환
        }
        return "미인식";
    }
}

