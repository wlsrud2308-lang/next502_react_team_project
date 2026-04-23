import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.repository.MemberRepository;
import bitc.next502.next502_backend.service.OcrService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class VerificationService {
    private final OcrService ocrService;
    private final MemberRepository memberRepository;

    @Transactional
    public String verifyLessorDocs(Long memberId, String idCardText, String bizRegText, String landTitleText) {
        MemberEntity member = memberRepository.findById(memberId)
                .orElseThrow(() -> new RuntimeException("회원을 찾을 수 없습니다."));

        // 1. 각 서류에서 이름 추출
        String nameFromId = ocrService.extractName(idCardText);
        String nameFromBiz = ocrService.extractName(bizRegText);
        String nameFromLand = ocrService.extractName(landTitleText);

        // 2. 이름 대조 (NPE 방지를 위해 Objects.equals 또는 null 체크 추가)
        // member.getName()은 이전에 MemberEntity에서 명시한 'name' 필드여야 합니다.
        String targetName = member.getName();

        boolean isIdOk = targetName.equals(nameFromId);
        boolean isBizOk = targetName.equals(nameFromBiz);
        boolean isLandOk = targetName.equals(nameFromLand);

        // 3. 결과 반환 및 엔티티 업데이트
        if (isIdOk && isBizOk && isLandOk) {
            // MemberEntity에 Role을 변경하거나 인증 플래그를 세팅하는 로직을 넣으면 좋습니다.
            // member.updateLessorStatus(true);
            return "모든 서류 인증 성공";
        } else {
            // 어떤 서류가 실패했는지 상세히 알려줌
            StringBuilder failureReason = new StringBuilder("인증 실패: ");
            if (!isIdOk) failureReason.append("[신분증 이름 불일치] ");
            if (!isBizOk) failureReason.append("[사업자등록증 이름 불일치] ");
            if (!isLandOk) failureReason.append("[등기부등본 이름 불일치] ");

            return failureReason.toString();
        }
    }
}