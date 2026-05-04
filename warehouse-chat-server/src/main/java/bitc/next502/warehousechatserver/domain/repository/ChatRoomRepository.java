package bitc.next502.warehousechatserver.domain.repository;

import bitc.next502.warehousechatserver.domain.entity.ChatRoomEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

// ChatRoomEntity의 데이터베이스 접근을 담당하는 Repository
public interface ChatRoomRepository extends JpaRepository<ChatRoomEntity, Long> {

//  창고 ID와 사용자 ID를 기준으로 이미 생성된 채팅방이 있는지 조회
//  첫번째 매개변수 : warehouseId 창고 고유 ID
//  두번째 매개변수 : userId 채팅을 시도하는 사용자 식별자
//  반환값 : 조건에 맞는 채팅방 엔티
  Optional<ChatRoomEntity> findByWarehouseIdAndUserId(Long warehouseId, String userId);
}
