package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.dto.BusinessLicenseDTO;
import lombok.extern.slf4j.Slf4j;
import net.sourceforge.tess4j.Tesseract;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@Slf4j
@Service
public class OcrService {

    @Value("${ocr.tesseract.datapath}")
    private String tessDataPath;

    public BusinessLicenseDTO extractBusinessLicense(MultipartFile file) throws Exception {
        BufferedImage original = ImageIO.read(new ByteArrayInputStream(file.getBytes()));
        if (original == null) {
            throw new IllegalArgumentException("이미지를 읽을 수 없습니다. 파일 형식을 확인하세요.");
        }
        log.info("[OCR] 원본 이미지 크기: {}x{}", original.getWidth(), original.getHeight());

        BufferedImage processed = preprocessImage(original);

        Path tempFile = Files.createTempFile("ocr_", ".png");
        ImageIO.write(processed, "png", tempFile.toFile());

        try {
            Tesseract tesseract = new Tesseract();
            tesseract.setDatapath(tessDataPath);
            tesseract.setLanguage("kor+eng");
            tesseract.setVariable("user_defined_dpi", "300");
            tesseract.setPageSegMode(6);

            String rawText = tesseract.doOCR(tempFile.toFile());
            log.info("[OCR] 추출된 raw text:\n{}", rawText);

            // ========================================================

            log.info("=================================================");
            log.info("[OCR] --- 사업자 종목 검증 로직 진입! ---");
            validateBusinessSector(rawText);
            log.info("[OCR] --- 검증 무사 통과! (서비스업 맞음) ---");
            log.info("=================================================");
            // ========================================================


            return parseLicenseText(rawText);

        } finally {
            Files.deleteIfExists(tempFile);
        }
    }


    private void validateBusinessSector(String text) {

        String cleanText = text.replaceAll("\\s+", "");


        boolean isValid = cleanText.contains("서비스") ||
                cleanText.contains("창고") ||
                cleanText.contains("보관") ||
                cleanText.contains("임대");

        log.info("[OCR] 발견된 키워드 상태 (true면 통과, false면 반려) : {}", isValid);

        if (!isValid) {
            log.warn("[OCR] 서비스업/창고업 키워드가 없어 고의로 에러를 발생시킵니다!!!");

            throw new IllegalArgumentException("반려: 서비스업(또는 창고/보관업) 사업자만 등록이 가능합니다.");
        }
    }

    private BufferedImage preprocessImage(BufferedImage src) {
        int width = src.getWidth();
        int height = src.getHeight();

        double scale = (width < 1500) ? 2.0 : 1.0;
        int newWidth = (int) (width * scale);
        int newHeight = (int) (height * scale);

        log.info("[OCR] 전처리: {}x{} → {}x{} (scale {}배)", width, height, newWidth, newHeight, scale);

        BufferedImage result = new BufferedImage(newWidth, newHeight, BufferedImage.TYPE_BYTE_GRAY);
        Graphics2D g = result.createGraphics();
        g.setRenderingHint(RenderingHints.KEY_INTERPOLATION, RenderingHints.VALUE_INTERPOLATION_BICUBIC);
        g.setRenderingHint(RenderingHints.KEY_RENDERING, RenderingHints.VALUE_RENDER_QUALITY);
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        g.drawImage(src, 0, 0, newWidth, newHeight, null);
        g.dispose();

        return result;
    }


    private BusinessLicenseDTO parseLicenseText(String text) {
        String registerNumber = null;
        String companyName = null;
        String representativeName = null;
        String businessAddress = null;

        // 사업자번호
        registerNumber = extractRegisterNumber(text);

        String[] lines = text.split("\\r?\\n");

        for (int i = 0; i < lines.length; i++) {
            String line = lines[i].trim();
            if (line.isEmpty()) continue;

            // 상호
            if (companyName == null && line.matches(".*상\\s*호.*")) {
                companyName = extractValueAfterColon(line);
            }
            // 대표자
            else if (representativeName == null && line.matches(".*(성\\s*명|대\\s*표|성\\s*[A-Za-z가-힣]?\\s*[:：]).*")) {
                String value = extractValueAfterColon(line);
                if (value != null) {
                    int idx = value.indexOf("생");
                    if (idx > 0) value = value.substring(0, idx).trim();
                    representativeName = value.replaceAll("[a-zA-Z:]", "").trim();
                }
            }
            // 주소
            else if (businessAddress == null && line.matches(".*사\\s*업\\s*장.*") && !line.matches(".*(단\\s*위|적\\s*용).*")) {
                String value = extractValueAfterColon(line);

                if (value != null && i + 1 < lines.length) {
                    String nextLine = lines[i + 1].trim();

                    if (!nextLine.isEmpty()
                            && !nextLine.matches(".*(업\\s*태|종\\s*목|업\\s*의|종\\s*류|발\\s*급|공\\s*동|전\\s*화|Fax|E-mail|사업자|전자).*")
                            && nextLine.length() < 50) {
                        value = value + " " + nextLine;


                        if (i + 2 < lines.length) {
                            String nextNextLine = lines[i + 2].trim();
                            if (nextNextLine.matches("^[가-힣a-zA-Z0-9)]+$") && nextNextLine.length() < 5) {
                                value = value + nextNextLine;
                            }
                        }
                    }
                }
                if (value != null) {
                    value = value.replace("톡별시", "특별시").replace("툭별시", "특별시");
                }
                businessAddress = value;
            }
        }

        log.info("[OCR] 파싱 결과 - 상호:{}, 번호:{}, 대표자:{}, 주소:{}",
                companyName, registerNumber, representativeName, businessAddress);

        return BusinessLicenseDTO.builder()
                .companyName(companyName)
                .registerNumber(registerNumber)
                .representativeName(representativeName)
                .businessAddress(businessAddress)
                .message("OCR 분석 완료 (Tesseract). 인식 결과를 확인 후 수정해주세요.")
                .build();
    }

    private String extractRegisterNumber(String text) {
        Pattern pattern = Pattern.compile("(\\d{3})\\s*-\\s*(\\d{2})\\s*-\\s*(\\d{5})");
        Matcher matcher = pattern.matcher(text);
        if (matcher.find()) {
            return matcher.group(1) + "-" + matcher.group(2) + "-" + matcher.group(3);
        }
        return null;
    }


    private String extractValueAfterColon(String line) {

        Pattern pattern = Pattern.compile("[:：]\\s*(.+)");
        Matcher matcher = pattern.matcher(line);
        if (matcher.find()) {
            String value = matcher.group(1).trim();
            value = value.replaceAll("[:：]\\s*$", "").trim();
            if (value.length() >= 1 && value.length() <= 200) {
                return value;
            }
        }
        return null;
    }
}