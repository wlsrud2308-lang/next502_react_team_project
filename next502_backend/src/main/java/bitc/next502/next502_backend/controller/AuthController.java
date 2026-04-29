package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.KakaoLoginDTO;
import bitc.next502.next502_backend.domain.dto.MemberDTO;
import bitc.next502.next502_backend.domain.dto.ResponseDTO;
import bitc.next502.next502_backend.domain.dto.TokenDTO;
import bitc.next502.next502_backend.service.AuthService;
import bitc.next502.next502_backend.service.MemberService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Slf4j
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

  private final MemberService memberService;
  private final AuthService authService;

  @PostMapping("/login")
  public ResponseEntity<?> login(@RequestBody Map<String, String> loginData) {
    try {
      String userId = loginData.get("userId");
      String userPw = loginData.get("userPw");

      ResponseDTO jwtToken = memberService.getJwtAuthenticate(userId, userPw);
      return ResponseEntity.ok().body(jwtToken);
    }
    catch (Exception e) {
      log.warn("일반 로그인 실패: {}", e.getMessage());
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("로그인 실패");
    }
  }

  @PostMapping("/signup")
  public ResponseEntity<?> signup(@RequestBody MemberDTO member) {
    try {
      ResponseDTO jwtToken = memberService.signupMember(member);
      return ResponseEntity.ok().body(jwtToken);
    }
    catch (IllegalArgumentException e) {
      String resData = "회원 가입 실패\n" + e.getMessage();
      return ResponseEntity.badRequest().body(resData);
    }
  }

  @GetMapping("/logout")
  public ResponseEntity<?> logout() {
    return ResponseEntity.ok("로그아웃");
  }

  @PostMapping("/refresh")
  public ResponseEntity<?> refreshToken(@RequestParam String refreshToken) {
    ResponseDTO newAccessToken = memberService.refreshAccessToken(refreshToken);
    return ResponseEntity.ok(newAccessToken);
  }

  @PostMapping("/kakao")
  public ResponseEntity<?> loginWithKakao(@RequestBody KakaoLoginDTO request) {
    log.info("카카오 로그인 요청 진입 - kakaoId: {}, nickname: {}",
            request.getKakaoId(), request.getNickname());

    try {
      TokenDTO tokenDTO = authService.loginKakao(request);

      ResponseDTO responseDTO = ResponseDTO.builder()
              .id(tokenDTO.getId())
              .accessToken(tokenDTO.getAccessToken())
              .refreshToken(tokenDTO.getRefreshToken())
              .role("ROLE_MEMBER")
              .build();

      log.info("카카오 로그인 성공 - kakaoId: {}", request.getKakaoId());
      return ResponseEntity.ok(responseDTO);
    }
    catch (Exception e) {
      log.error("카카오 로그인 실패 - kakaoId: {}, error: {}",
              request.getKakaoId(), e.getMessage(), e);
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
              .body("카카오 로그인 실패: " + e.getMessage());
    }
  }
}