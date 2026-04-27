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
            "WHERE r.warehouse.id = :warehouseId " +
            "AND r.buyer.id = :buyerId")
    Optional<ChatRoomEntity> findExistRoom(@Param("warehouseId") Long warehouseId, @Param("buyerId") Long buyerId);

    // 2. 내 채팅방 목록 조회 (수정 시간 역순)
    @Query("SELECT r FROM ChatRoomEntity r " +
            "WHERE r.buyer = :member OR r.provider = :member " +
            "ORDER BY r.updateDate DESC")
    List<ChatRoomEntity> findAllMyRooms(@Param("member") MemberEntity member);
}