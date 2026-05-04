package bitc.next502.next502_backend.domain.dto;

import bitc.next502.next502_backend.domain.entity.ChatType;
import lombok.*;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
public class ChatMessageDTO {

    private Long id;
    private Long chatRoomId;
    private Long senderId;

    private String senderNick; // 플러터 UI에 팝업이나 상단에 띄워줄 닉네임
    private String message;
    private ChatType chatType; // TEXT, IMAGE, VOICE 등
    private String fileUrl; // 이미지 업로드 시 주소

    // 👈 LocalDateTime 대신 String 타입으로 선언하여 JSON 파싱 에러를 원천 차단합니다.
    private String createDate;

    // 👈 기본값 'N' 처리
    @Builder.Default
    private String isReadYn = "N";
}
