package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface WarehouseRepository extends JpaRepository<WarehouseEntity, Long> {

    // 리액트용 상세 검색 (기존 유지)
    @Query("SELECT w FROM WarehouseEntity w " +
        "WHERE (:addr IS NULL OR w.address LIKE %:addr%) " +
        "AND (:size IS NULL OR w.sizeRank LIKE %:size%) " +
        "AND (:name IS NULL OR w.name LIKE %:name%)")
    List<WarehouseEntity> searchWarehouses(
        @Param("addr") String addr,
        @Param("size") String size,
        @Param("name") String name
    );

    // 플러터용 통합 검색 (신규 추가: 키워드 하나로 이름/주소 검색)
    @Query("SELECT w FROM WarehouseEntity w WHERE " +
        "(:keyword IS NULL OR w.name LIKE %:keyword% OR w.address LIKE %:keyword%) " +
        "AND (:storageType IS NULL OR w.storageType = :storageType)")
    List<WarehouseEntity> findWarehousesUnified(
        @Param("keyword") String keyword,
        @Param("storageType") String storageType
    );

    List<WarehouseEntity> findByMember(MemberEntity member);
}