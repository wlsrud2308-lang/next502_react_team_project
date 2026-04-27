package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface WarehouseRepository extends JpaRepository<WarehouseEntity, Long> {

    // 1. 다중 조건 검색 (바뀐 필드명 반영)
    @Query("SELECT w FROM WarehouseEntity w " +
            "WHERE (:addr IS NULL OR w.address LIKE %:addr%) " +
            "AND (:size IS NULL OR w.sizeRank LIKE %:size%) " +
            "AND (:name IS NULL OR w.name LIKE %:name%)")
    List<WarehouseEntity> searchWarehouses(
            @Param("addr") String addr,
            @Param("size") String size,
            @Param("name") String name
    );

    // 2. 특정 사용자가 등록한 창고 목록 조회
    List<WarehouseEntity> findByMember_UserId(String userId);
}
