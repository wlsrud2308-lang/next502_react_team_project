package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.ChatRoomEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoomEntity, Long> {

    @Query("SELECT r FROM ChatRoomEntity r " +
            "WHERE r.warehouse.warehouseSeq = :warehouseSeq " +
            "AND r.buyer.userSeq = :userSeq")
    Optional<ChatRoomEntity> findExistRoom(@Param("warehouseSeq") Long warehouseSeq, @Param("userSeq") Long userSeq);

    // 닉네임이나 메서드명 에러를 피하기 위해 직접 쿼리 작성
    @Query("SELECT r FROM ChatRoomEntity r " +
            "WHERE r.buyer = :member OR r.provider = :member " +
            "ORDER BY r.updateDate DESC")
    List<ChatRoomEntity> findAllMyRooms(@Param("member") MemberEntity member);
}
