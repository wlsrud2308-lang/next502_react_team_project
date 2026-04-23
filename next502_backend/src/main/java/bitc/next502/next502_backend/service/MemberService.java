package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.config.jwt.JwtTokenProvider;
import bitc.next502.next502_backend.domain.dto.MemberDTO;
import bitc.next502.next502_backend.domain.dto.ResponseDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.RefreshTokenEntity;
import bitc.next502.next502_backend.domain.entity.Role;
import bitc.next502.next502_backend.domain.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;

@Service
@RequiredArgsConstructor
public class MemberService {

  private final MemberRepository memberRepository;
  private final JwtTokenProvider jwtTokenProvider;
  private final AuthenticationManager authenticationManager;
  private final PasswordEncoder passwordEncoder;
  private final RefreshTokenService refreshTokenService;

  public ResponseDTO getJwtAuthenticate(String userId, String userPw) {
    Authentication authentication = authenticationManager.authenticate(new UsernamePasswordAuthenticationToken(userId, userPw));

    MemberEntity member = (MemberEntity) authentication.getPrincipal();

    String accessToken = jwtTokenProvider.generateToken(member, Duration.ofMinutes(5));
    RefreshTokenEntity refreshToken = refreshTokenService.generateRefreshToken(member);

    return ResponseDTO.builder()
        .accessToken(accessToken)
        .refreshToken(refreshToken.getRefreshToken())
        .build();
  }

  public String signupMember(MemberDTO member) {
    if (memberRepository.existsByUserId(member.getUserId())) {
      throw new IllegalArgumentException("이미 존재하는 사용자 입니다.");
    }

    if (memberRepository.existsByUserEmail(member.getUserEmail())) {
      throw new IllegalArgumentException("이미 존재하는 이메일 입니다.");
    }

    String encodedPassword = passwordEncoder.encode(member.getUserPw());

    MemberEntity newMember = MemberEntity.builder()
        .userId(member.getUserId())
        .password(encodedPassword)
        .userEmail(member.getUserEmail())
        .userNick(member.getUserNick())
        .role(Role.ROLE_MEMBER)
        .build();

    memberRepository.save(newMember);

    return "회원 가입 성공";
  }

  @Transactional
  public void deleteMember(String userId) {
    MemberEntity member = memberRepository.findByUserId(userId).orElseThrow(() -> new IllegalArgumentException("사용자를 찾을 수 없습니다."));

    memberRepository.delete(member);
  }

  public ResponseDTO refreshAccessToken(String refreshToken) {
    String newAccessToken = refreshTokenService.findMemberByToken(refreshToken)
        .map(member -> jwtTokenProvider.generateToken(member, Duration.ofMinutes(5)))
        .orElseThrow(() -> new IllegalArgumentException("유효하지 않거나 만료된 리프레시 토큰 입니다."));

    return ResponseDTO.builder()
        .accessToken(newAccessToken)
        .build();
  }
}
