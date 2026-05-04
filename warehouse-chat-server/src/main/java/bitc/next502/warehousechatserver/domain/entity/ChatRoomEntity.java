package bitc.next502.warehousechatserver.domain.entity;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

// DB의 't_chat_room' 테이블과 매핑되는 엔티티 클래스
@Entity
@Table(name = "t_chat_room")
@Getter
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ChatRoomEntity {

//  채팅방 고유 ID (PK)
  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

//  채팅이 연결된 창고(게시물)의 ID
  private Long warehouseId;
  
//  창고 소유자(제공자)의 식별자
  private String providerId;
  
//  채팅을 건 사용자(문의자)의 식별자
  private String userId;

//  채팅방 생성 시간
  @Builder.Default
  private LocalDateTime createdAt = LocalDateTime.now();
}
