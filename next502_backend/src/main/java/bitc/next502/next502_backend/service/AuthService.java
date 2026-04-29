package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.config.jwt.JwtTokenProvider;
import bitc.next502.next502_backend.domain.dto.KakaoLoginDTO;
import bitc.next502.next502_backend.domain.dto.TokenDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.Role;
import bitc.next502.next502_backend.domain.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class AuthService {

    private final MemberRepository memberRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    @Transactional
    public TokenDTO loginKakao(KakaoLoginDTO request) {
        // 1. 카카오 ID로 기존 회원인지 확인
        MemberEntity member = memberRepository.findByKakaoId(request.getKakaoId())
                .orElseGet(() -> {
                    // 2. 신규 회원이라면 자동 회원가입 진행
                    String tempPassword = passwordEncoder.encode(UUID.randomUUID().toString());

                    MemberEntity newMember = MemberEntity.builder()
                            .userId("KAKAO_" + request.getKakaoId())
                            .password(tempPassword)
                            .userNick(request.getNickname() != null ? request.getNickname() : "카카오유저")
                            .name("카카오사용자")
                            .birthDate("2026-04-28")
                            .tel("010-0000-0000")
                            .role(Role.ROLE_MEMBER)
                            .kakaoId(request.getKakaoId())
                            .build();
                    return memberRepository.save(newMember);
                });


        String accessToken = jwtTokenProvider.generateToken(member, Duration.ofDays(1));

        // 4. 생성된 토큰을 TokenDTO에 담아서 반환
        return TokenDTO.builder()
                .id(member.getId())
                .grantType("Bearer")
                .accessToken(accessToken)
                .accessTokenExpiresIn(Duration.ofDays(1).toMillis())
                .build();
    }
}