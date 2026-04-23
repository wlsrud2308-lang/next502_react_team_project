package bitc.next502.next502_backend.domain.dto;

import bitc.next502.next502_backend.domain.entity.Role;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class MemberDTO {
  private String userId;
  private String userPw;
  private String userNick;
  private String name;
  private String birthDate;
  private String tel;
  private String userEmail;
  private Role role;
}
