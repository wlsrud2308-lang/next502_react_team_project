package bitc.next502.next502_backend.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class KakaoLoginDTO {

    // 카카오에서 발급받은 액세스 토큰
    private String accessToken;

    // 카카오 사용자의 고유 식별자

    private Long kakaoId;

    // 사용자의 카카오 닉네임 (선택 사항)
    private String nickname;

    // 사용자의 카카오 이메일
    private String email;
}