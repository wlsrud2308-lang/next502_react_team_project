package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.Collections;

@Entity
@Table(name = "t_jwt_member")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class MemberEntity extends BaseTimeEntity implements UserDetails {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  @Column(name = "id")
  private Long id;

  @Column(name = "user_id", nullable = false, unique = true)
  private String userId;


  @Column(name = "user_pw", nullable = false)
  private String password;

  @Column(name = "user_nick", nullable = false)
  private String userNick;

  @Column(nullable = false, length = 45)
  private String name;

  @Column(name = "birth_date", nullable = false, length = 10)
  private String birthDate;

  @Column(nullable = false, length = 20)
  private String tel;

  @Column(name = "user_email")
  private String userEmail;

  @Enumerated(EnumType.STRING)
  private Role role;

  @Column(name = "business_name", length = 100)
  private String businessName;

  @Column(name = "business_number", length = 50)
  private String businessNumber;

  @Column(name = "business_address", length = 200)
  private String businessAddress;

  // --- 카카오 고유 식별 번호 필드 ---
  @Column(name = "kakao_id", unique = true)
  private Long kakaoId;
  // ---------------------------------------

  @Override
  public Collection<? extends GrantedAuthority> getAuthorities() {
    return Collections.singleton(new SimpleGrantedAuthority(role.name()));
  }

  @Override
  public String getUsername() {
    return this.userId;
  }

  @Override
  public String getPassword() {
    return this.password;
  }

  @Override
  public boolean isAccountNonExpired() {
    return true;
  }

  @Override
  public boolean isAccountNonLocked() {
    return true;
  }

  @Override
  public boolean isCredentialsNonExpired() {
    return true;
  }

  @Override
  public boolean isEnabled() {
    return true;
  }
}