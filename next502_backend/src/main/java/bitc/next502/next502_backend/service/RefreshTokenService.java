package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.config.jwt.JwtTokenProvider;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.RefreshTokenEntity;
import bitc.next502.next502_backend.domain.repository.RefreshTokenRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RefreshTokenService {

  private final RefreshTokenRepository refreshTokenRepository;
  private final JwtTokenProvider jwtTokenProvider;

  public RefreshTokenEntity generateRefreshToken(MemberEntity member) {
    String token = jwtTokenProvider.generateToken(member, Duration.ofDays(1));

    RefreshTokenEntity refreshToken = RefreshTokenEntity.builder()
        .member(member)
        .refreshToken(token)
        .expiryDate(LocalDateTime.now().plusDays(1))
        .build();

    return refreshTokenRepository.save(refreshToken);
  }

  public boolean validateRefreshToken(String token) {
    return refreshTokenRepository.findByRefreshToken(token)
        .map(refreshToken -> !refreshToken.isExpired())
        .orElse(false);
  }

  @Transactional
  public void deleteRefreshToken(MemberEntity member) {
    refreshTokenRepository.deleteByMember(member);
  }

  public Optional<MemberEntity> findMemberByToken(String token) {
    return refreshTokenRepository.findByRefreshToken(token)
        .filter(refreshToken -> !refreshToken.isExpired())
        .map(RefreshTokenEntity::getMember);
  }
}
