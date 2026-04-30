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

    // --- 기존 카카오 로그인 로직 ---
    @Transactional
    public TokenDTO loginKakao(KakaoLoginDTO request) {
        MemberEntity member = memberRepository.findByKakaoId(request.getKakaoId())
                .orElseGet(() -> {
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

        return TokenDTO.builder()
                .id(member.getId())
                .grantType("Bearer")
                .accessToken(accessToken)
                .accessTokenExpiresIn(Duration.ofDays(1).toMillis())
                .build();
    }

    // --- 추가: 아이디 찾기 로직 ---
    @Transactional(readOnly = true)
    public String findUserId(String name, String tel) {
        return memberRepository.findByNameAndTel(name, tel)
                .map(MemberEntity::getUserId)
                .orElseThrow(() -> new RuntimeException("일치하는 회원을 찾을 수 없습니다."));
    }

    // 추가: 비밀번호 재설정 전 사용자 확인 로직
    @Transactional(readOnly = true)
    public boolean checkUserForPasswordReset(String userId, String name, String tel) {
        return memberRepository.findByUserIdAndNameAndTel(userId, name, tel).isPresent();
    }

    // 추가: 비밀번호 실제 변경 로직
    @Transactional
    public void resetPassword(String userId, String newUserPw) {
        MemberEntity member = memberRepository.findByUserId(userId)
                .orElseThrow(() -> new RuntimeException("사용자를 찾을 수 없습니다."));

        // 새로운 비밀번호 암호화 후 저장
        member.setPassword(passwordEncoder.encode(newUserPw));
        memberRepository.save(member);
    }
}