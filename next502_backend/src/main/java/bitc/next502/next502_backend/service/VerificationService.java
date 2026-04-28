package bitc.next502.next502_backend.service;

/*
 * VerificationService
 * --------------------
 * 임대인의 3종 서류(신분증/사업자등록증/등기부등본)에서 이름을 추출해
 * 회원 정보와 대조하는 검증 로직.
 *
 * [현재 비활성화 상태]
 * 사유: OcrService를 Tesseract → CLOVA OCR로 교체하면서 옛 메서드
 *       (extractName, getOcrText)가 제거됨.
 *       이 서비스는 1번 영역(공급자 가입 OCR) 작업 범위 밖이라 일단 보존만 함.
 *
 * [부활 시 작업]
 *  1. OcrService에 사업자등록증 외 신분증·등기부등본 분석 메서드 추가
 *  2. CLOVA OCR 일반 도메인 또는 신분증 특화 템플릿 도메인 추가 등록
 *  3. import 및 @Service 주석 해제 후 본 코드 복원
 *  4. VerificationController 신규 작성
 */

//import bitc.next502.next502_backend.domain.entity.MemberEntity;
//import bitc.next502.next502_backend.domain.repository.MemberRepository;
//import bitc.next502.next502_backend.service.OcrService;
//import jakarta.transaction.Transactional;
//import lombok.RequiredArgsConstructor;
//import org.springframework.stereotype.Service;
//
//@Service
//@RequiredArgsConstructor
//public class VerificationService {
//    private final OcrService ocrService;
//    private final MemberRepository memberRepository;
//
//    @Transactional
//    public String verifyLessorDocs(Long memberId, String idCardText, String bizRegText, String landTitleText) {
//        MemberEntity member = memberRepository.findById(memberId)
//                .orElseThrow(() -> new RuntimeException("회원을 찾을 수 없습니다."));
//
//        // 1. 각 서류에서 이름 추출
//        String nameFromId = ocrService.extractName(idCardText);
//        String nameFromBiz = ocrService.extractName(bizRegText);
//        String nameFromLand = ocrService.extractName(landTitleText);
//
//        // 2. 이름 대조 (NPE 방지를 위해 Objects.equals 또는 null 체크 추가)
//        String targetName = member.getName();
//
//        boolean isIdOk = targetName.equals(nameFromId);
//        boolean isBizOk = targetName.equals(nameFromBiz);
//        boolean isLandOk = targetName.equals(nameFromLand);
//
//        // 3. 결과 반환 및 엔티티 업데이트
//        if (isIdOk && isBizOk && isLandOk) {
//            return "모든 서류 인증 성공";
//        } else {
//            StringBuilder failureReason = new StringBuilder("인증 실패: ");
//            if (!isIdOk) failureReason.append("[신분증 이름 불일치] ");
//            if (!isBizOk) failureReason.append("[사업자등록증 이름 불일치] ");
//            if (!isLandOk) failureReason.append("[등기부등본 이름 불일치] ");
//
//            return failureReason.toString();
//        }
//    }
//}