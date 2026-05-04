package bitc.next502.next502_backend.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

// Firebase 인증 토큰 요청 시 클라이언트에게 반환하는 DTO
@Getter
@NoArgsConstructor(force = true)
@AllArgsConstructor
public class TokenResponseDTO {

  /** 발급된 Firebase Custom Token 문자열 */
  private final String token;
}
