package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.MemberDTO;
import bitc.next502.next502_backend.domain.dto.ResponseDTO;
import bitc.next502.next502_backend.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

  private final MemberService memberService;

  @PostMapping("/login")
  public ResponseEntity<?> login(@RequestBody Map<String, String> loginData) {
    try {
      String userId = loginData.get("userId");
      String userPw = loginData.get("userPw");

      ResponseDTO jwtToken = memberService.getJwtAuthenticate(userId, userPw);
      return ResponseEntity.ok().body(jwtToken);
    }
    catch (Exception e) {
      System.out.println("오류 발생 : " + e.getMessage());
      System.out.println(e.getStackTrace()); // 스크린샷에 있던 이 줄도 유지해 드렸습니다
      return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body("로그인 실패");
    }
  }

  @PostMapping("/signup")
  public ResponseEntity<?> signup(@RequestBody MemberDTO member) {
    try {
      String resData = memberService.signupMember(member);
      return ResponseEntity.ok().body(resData);
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
}
