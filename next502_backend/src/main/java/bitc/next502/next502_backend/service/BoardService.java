package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.entity.BoardEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.repository.BoardRepository;
import bitc.next502.next502_backend.domain.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true) // 기본적으로 읽기 전용으로 설정 (성능 최적화)
public class BoardService {

    private final BoardRepository boardRepository;
    private final MemberRepository memberRepository;

    // 1. 카테고리별 목록 조회
    public List<BoardEntity> selectBoardListByCategory(String category) {
        // 대소문자 구분 없이 처리하기 위해 upperCase 사용 권장
        return boardRepository.findByCategoryOrderByBoardIdDesc(category.toUpperCase());
    }

    // 2. 게시글 상세 조회
    public BoardEntity selectBoardDetail(Long boardId) {
        return boardRepository.findById(boardId)
                .orElseThrow(() -> new IllegalArgumentException("해당 게시글이 존재하지 않습니다. ID: " + boardId));
    }

    // 3. 게시글 등록
    @Transactional // 쓰기 작업이므로 Transactional 추가
    public void insertBoard(BoardEntity board, Long memberId) {
        // 작성자(Member) 정보 조회 후 매핑
        MemberEntity writer = memberRepository.findById(memberId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 회원입니다. ID: " + memberId));

        board.setWriter(writer);
        board.setCategory(board.getCategory().toUpperCase()); // 카테고리 대문자로 저장
        boardRepository.save(board);
    }

    // 4. 게시글 수정
    @Transactional
    public void updateBoard(Long boardId, BoardEntity updatedBoard) {
        BoardEntity board = boardRepository.findById(boardId)
                .orElseThrow(() -> new IllegalArgumentException("해당 게시글이 존재하지 않습니다."));

        // 변경 감지(Dirty Checking)를 이용한 수정
        board.setTitle(updatedBoard.getTitle());
        board.setContent(updatedBoard.getContent());
        board.setCategory(updatedBoard.getCategory().toUpperCase());

        // JpaRepository.save()를 명시적으로 호출하지 않아도 @Transactional에 의해 자동 반영됨
    }
    // 4-1. [ADMIN] 관리자 답변 등록 및 수정
    @Transactional
    public void updateReply(Long boardId, String reply) {
        // 1. 게시글 존재 여부 확인
        BoardEntity board = boardRepository.findById(boardId)
                .orElseThrow(() -> new IllegalArgumentException("해당 게시글이 존재하지 않습니다. ID: " + boardId));

        // 2. 답변 내용 업데이트 (Dirty Checking 활용)
        board.setReply(reply);

        // 추가로 답변 완료 상태값 등이 있다면 여기서 함께 처리 가능합니다.
    }

    // 5. 게시글 삭제
    @Transactional
    public void deleteBoard(Long boardId) {
        if (!boardRepository.existsById(boardId)) {
            throw new IllegalArgumentException("이미 삭제되었거나 존재하지 않는 게시글입니다.");
        }
        boardRepository.deleteById(boardId);
    }
}
