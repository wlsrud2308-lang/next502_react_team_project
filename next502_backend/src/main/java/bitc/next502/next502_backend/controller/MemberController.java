package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.MemberDTO;
import bitc.next502.next502_backend.service.MemberService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/member")
@RequiredArgsConstructor
public class MemberController {

    private final MemberService memberService;

    // 내 정보 조회 API
    @GetMapping("/me")
    public ResponseEntity<MemberDTO> getMyInfo(@AuthenticationPrincipal UserDetails userDetails) {

        MemberDTO memberDTO = memberService.getMemberInfo(userDetails.getUsername());
        return ResponseEntity.ok(memberDTO);
    }
}