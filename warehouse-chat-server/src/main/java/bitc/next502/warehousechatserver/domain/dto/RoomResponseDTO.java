package bitc.next502.warehousechatserver.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

// 채팅방 정보 요청 시 클라이언트에게 반환하는 DTO
@Getter
@NoArgsConstructor(force = true)
@AllArgsConstructor
public class RoomResponseDTO {
  
  /** 생성되거나 조회된 채팅방의 식별자 (예: room_1) */
  private final String roomId;
}
