package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "t_jwt_refresh_token")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class RefreshTokenEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  public Long id;

  @Lob
  @Column(nullable = false)
  private String refreshToken;

  @Column(nullable = false)
  private LocalDateTime expiryDate;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id")
  private MemberEntity member;

  public boolean isExpired() {
    return LocalDateTime.now().isAfter(this.expiryDate);
  }
}
