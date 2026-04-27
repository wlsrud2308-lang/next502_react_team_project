package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "t_jwt_refresh_token")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class RefreshTokenEntity {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id") // DB 컬럼명 매핑 [cite: 15]
  private Long id;

  @Column(name = "refresh_token", nullable = false, columnDefinition = "TEXT")
  private String refreshToken;

  @Column(name = "expiry_date", nullable = false)
  private LocalDateTime expiryDate;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "user_id")
  private MemberEntity member;

  public boolean isExpired() {
    return LocalDateTime.now().isAfter(this.expiryDate);
  }
}