package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.ChatRoomEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ChatRoomRepository extends JpaRepository<ChatRoomEntity, Long> {

    // 1. 기존 방 존재 여부 확인
    @Query("SELECT r FROM ChatRoomEntity r " +
            "WHERE r.warehouse.warehouse_id = :warehouseId " +
            "AND r.member.id = :memberId")
    Optional<ChatRoomEntity> findExistRoom(@Param("warehouseId") Long warehouseId, @Param("memberId") Long memberId);

    // 2. 내 채팅방 목록 조회 (modifiedDate -> updateDate로 수정)
    @Query("SELECT r FROM ChatRoomEntity r " +
            "WHERE r.member = :member OR r.provider = :member " +
            "ORDER BY r.updateDate DESC")
    List<ChatRoomEntity> findAllMyRooms(@Param("member") MemberEntity member);
}
