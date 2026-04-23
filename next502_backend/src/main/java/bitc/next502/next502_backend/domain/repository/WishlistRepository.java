package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.ProductEntity;
import bitc.next502.next502_backend.domain.entity.WishlistEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface WishlistRepository extends JpaRepository<WishlistEntity, Long> {
    // 내가 찜한 목록 전체 조회
    List<WishlistEntity> findByMember(MemberEntity member);

    // 이미 찜했는지 확인 (중복 방지)
    boolean existsByMemberAndProduct(MemberEntity member, ProductEntity product);

    // 찜 취소 (삭제)
    void deleteByMemberAndProduct(MemberEntity member, ProductEntity product);
}