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
    Authentication authentication = authenticationManager.authenticate(
            new UsernamePasswordAuthenticationToken(userId, userPw));

    MemberEntity member = (MemberEntity) authentication.getPrincipal();

    String accessToken = jwtTokenProvider.generateToken(member, Duration.ofMinutes(30));
    RefreshTokenEntity refreshToken = refreshTokenService.generateRefreshToken(member);

    
    return ResponseDTO.builder()
            .id(member.getId())
            .accessToken(accessToken)
            .refreshToken(refreshToken.getRefreshToken())
            .role(member.getRole().name())
            .build();
  }

  @Transactional
  public ResponseDTO signupMember(MemberDTO member) {
    if (memberRepository.existsByUserId(member.getUserId())) {
      throw new IllegalArgumentException("이미 존재하는 사용자 입니다.");
    }

    if (member.getUserEmail() != null && !member.getUserEmail().isBlank()
            && memberRepository.existsByUserEmail(member.getUserEmail())) {
      throw new IllegalArgumentException("이미 존재하는 이메일 입니다.");
    }

    String encodedPassword = passwordEncoder.encode(member.getUserPw());

    Role userRole = member.getRole();
    if (userRole == null || userRole == Role.ROLE_ADMIN) {
      userRole = Role.ROLE_MEMBER;
    }

    MemberEntity newMember = MemberEntity.builder()
            .userId(member.getUserId())
            .password(encodedPassword)
            .userEmail(member.getUserEmail())
            .userNick(member.getUserNick())
            .name(member.getName())
            .birthDate(member.getBirthDate())
            .tel(member.getTel())
            .role(userRole)
            .businessName(member.getBusinessName())
            .businessNumber(member.getBusinessNumber())
            .businessAddress(member.getBusinessAddress())
            .build();

    MemberEntity savedMember = memberRepository.save(newMember);

    String accessToken = jwtTokenProvider.generateToken(savedMember, Duration.ofMinutes(30));
    RefreshTokenEntity refreshToken = refreshTokenService.generateRefreshToken(savedMember);

    return ResponseDTO.builder()
            .id(savedMember.getId())
            .accessToken(accessToken)
            .refreshToken(refreshToken.getRefreshToken())
            .role(savedMember.getRole().name())
            .build();
  }

  public MemberDTO getMemberInfo(String userId) {
    MemberEntity member = memberRepository.findByUserId(userId)
            .orElseThrow(() -> new IllegalArgumentException("회원을 찾을 수 없습니다: " + userId));

    return MemberDTO.builder()
            .userId(member.getUserId())
            .userEmail(member.getUserEmail())
            .userNick(member.getUserNick())
            .name(member.getName())
            .birthDate(member.getBirthDate())
            .tel(member.getTel())
            .role(member.getRole())
            .businessName(member.getBusinessName())
            .businessNumber(member.getBusinessNumber())
            .businessAddress(member.getBusinessAddress())
            .build();
  }

  public ResponseDTO refreshAccessToken(String refreshToken) {
    MemberEntity member = refreshTokenService.findMemberByToken(refreshToken)
            .orElseThrow(() -> new IllegalArgumentException("유효하지 않거나 만료된 RefreshToken 입니다."));

    String newAccessToken = jwtTokenProvider.generateToken(member, Duration.ofMinutes(30));

    return ResponseDTO.builder()
            .id(member.getId())
            .accessToken(newAccessToken)
            .refreshToken(refreshToken)
            .role(member.getRole().name())
            .build();
  }
}