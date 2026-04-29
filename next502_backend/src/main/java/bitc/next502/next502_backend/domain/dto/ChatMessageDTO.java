package bitc.next502.next502_backend.domain.dto;

import bitc.next502.next502_backend.domain.entity.ChatType;
import lombok.*;
import java.time.LocalDateTime;

@Getter @Setter @Builder
@AllArgsConstructor @NoArgsConstructor
public class ChatMessageDTO {
    private Long id;
    private Long chatRoomId;
    private Long senderId;
    private String senderNick; // 추가 정보 (Flutter UI용)
    private String message;
    private ChatType chatType;
    private String fileUrl;
    private LocalDateTime createDate; // BaseTimeEntity의 시간
    private String isReadYn;
}
