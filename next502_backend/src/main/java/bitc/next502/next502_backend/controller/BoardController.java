package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.entity.BoardEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity; // 추가
import bitc.next502.next502_backend.service.BoardService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal; // 추가
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/board")
@RequiredArgsConstructor
public class BoardController {

  private final BoardService boardService;

  // 1. 목록 조회
  @GetMapping("/list/{category}")
  public ResponseEntity<List<BoardEntity>> selectBoardList(@PathVariable String category) {
    return ResponseEntity.ok(boardService.selectBoardListByCategory(category));
  }

  // 2. 상세 조회
  @GetMapping("/{boardId}")
  public ResponseEntity<BoardEntity> selectBoardDetail(@PathVariable Long boardId) {
    return ResponseEntity.ok(boardService.selectBoardDetail(boardId));
  }

  // 3. [ADMIN] 등록 - 로그인한 관리자의 ID를 서비스에 전달
  @PostMapping("/")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<String> insertBoard(
          @RequestBody BoardEntity board,
          @AuthenticationPrincipal MemberEntity loginMember // 현재 로그인 유저 정보 주입
  ) {
    // 서비스의 insertBoard(board, memberId) 호출
    boardService.insertBoard(board, loginMember.getId());
    return ResponseEntity.ok("등록 성공");
  }

  // 4. [ADMIN] 수정
  @PutMapping("/{boardId}")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<String> updateBoard(@PathVariable Long boardId, @RequestBody BoardEntity board) {
    boardService.updateBoard(boardId, board);
    return ResponseEntity.ok("수정 성공");
  }

  // 5. [ADMIN] 삭제
  @DeleteMapping("/{boardId}")
  @PreAuthorize("hasRole('ADMIN')")
  public ResponseEntity<String> deleteBoard(@PathVariable Long boardId) {
    boardService.deleteBoard(boardId);
    return ResponseEntity.ok("삭제 성공");
  }
  @PutMapping("/{boardId}/reply")
  @PreAuthorize("hasRole('ADMIN')") // 관리자만 접근 가능
  public ResponseEntity<String> updateReply(
          @PathVariable Long boardId,
          @RequestBody java.util.Map<String, String> request // JSON으로 오는 {"reply": "내용"}을 받음
  ) {
    String reply = request.get("reply");
    boardService.updateReply(boardId, reply);
    return ResponseEntity.ok("답변 등록 성공");
  }
}

