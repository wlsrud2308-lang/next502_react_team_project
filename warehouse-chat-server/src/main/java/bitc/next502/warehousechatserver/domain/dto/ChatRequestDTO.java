package bitc.next502.warehousechatserver.domain.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

// 채팅방 생성 또는 입장 요청 시 클라이언트로부터 전달받는 DTO
@Getter
@NoArgsConstructor
@AllArgsConstructor
public class ChatRequestDTO {
  
  /** 채팅방이 개설되는 창고(게시물)의 고유 ID */
  private Long warehouseId;
  
  /** 창고를 등록한 제공자(글쓴이)의 ID */
  private String providerId;
  
  /** 현재 채팅을 시도하는 사용자(구매자/문의자)의 ID */
  private String userId;
}
