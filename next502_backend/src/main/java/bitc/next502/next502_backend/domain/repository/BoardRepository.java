package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.BoardEntity;
import org.springframework.data.jpa.repository.JpaRepository; // import 필요
import java.util.List; // import 필요

public interface BoardRepository extends JpaRepository<BoardEntity, Long> {

    // 카테고리별 목록 조회 (최신순: boardId 기준 내림차순)
    List<BoardEntity> findByCategoryOrderByBoardIdDesc(String category);
}
