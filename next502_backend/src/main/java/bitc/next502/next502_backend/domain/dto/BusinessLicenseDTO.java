package bitc.next502.next502_backend.domain.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class BusinessLicenseDTO {

    /** 상호명*/
    private String companyName;

    /** 사업자등록번호 ( */
    private String registerNumber;

    /** 대표자명 */
    private String representativeName;

    /** 사업장 주소 */
    private String businessAddress;

    /** 처리 결과 메시지 — 디버깅·UI 표시용 */
    private String message;
}