package bitc.next502.next502_backend.controller;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/board")
@RequiredArgsConstructor
public class BoardController {

  @GetMapping({"", "/"})
  public ResponseEntity<?> selectBoardList() {
    return ResponseEntity.ok("게시판 목록 페이지");
  }

  @GetMapping("/{boardIdx}")
  public ResponseEntity<?> selectBoardDetail(@PathVariable int boardIdx) {
    return ResponseEntity.ok("게시판 상세 페이지\n글번호 : " + boardIdx);
  }

  @PostMapping("/")
  public ResponseEntity<?> insertBoard() {
    return ResponseEntity.ok("게시판 글 등록");
  }

  @PutMapping("/{boardIdx}")
  public ResponseEntity<?> updateBoard(@PathVariable int boardIdx) {
    return ResponseEntity.ok("게시판 글 수정\n글번호 : " + boardIdx);
  }

  @DeleteMapping("/{boardIdx}")
  public ResponseEntity<?> deleteBoard(@PathVariable int boardIdx) {
    return ResponseEntity.ok("게시판 글 삭제\n글번호 : " + boardIdx);
  }
}
