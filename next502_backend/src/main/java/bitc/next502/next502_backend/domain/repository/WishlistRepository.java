package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.entity.WishlistEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface WishlistRepository extends JpaRepository<WishlistEntity, Long> {

    // 서비스에서 사용하는 메서드 추가
    @Query("SELECT w FROM WishlistEntity w WHERE w.member = :member AND w.product = :product")
    Optional<WishlistEntity> findWish(@Param("member") MemberEntity member, @Param("product") WarehouseEntity product);

    // 기존 메서드들
    List<WishlistEntity> findByMember(MemberEntity member);

    boolean existsByMemberAndProduct(MemberEntity member, WarehouseEntity product);

    void deleteByMemberAndProduct(MemberEntity member, WarehouseEntity product);
}