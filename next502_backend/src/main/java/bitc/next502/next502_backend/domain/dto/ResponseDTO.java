package bitc.next502.next502_backend.domain.dto;

import lombok.*;

@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class ResponseDTO {

  private String accessToken;
  private String refreshToken;
}
