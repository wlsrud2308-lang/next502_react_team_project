package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.ChatMessageDTO;
import bitc.next502.next502_backend.domain.entity.ChatMessageEntity;
import bitc.next502.next502_backend.domain.entity.ChatType;
import bitc.next502.next502_backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.stereotype.Controller;

@Controller
@RequiredArgsConstructor
public class ChatStompController {

    private final SimpMessageSendingOperations messagingTemplate;
    private final ChatService chatService;

    @MessageMapping("/chat/message")
    public void message(ChatMessageDTO messageDto) { // ChatMessageEntity 대신 DTO 사용

        // 1. 시스템 메시지 처리 (입장 등)
        if (ChatType.SYSTEM.equals(messageDto.getChatType())) {
            // senderNick은 보통 Flutter에서 보내거나 DB 조회 후 세팅
            messageDto.setMessage(messageDto.getSenderNick() + "님이 입장하셨습니다.");
        }

        // 2. 서비스 로직 호출 및 저장된 데이터(시간 등 포함) 수신
        // 서비스에서 저장 후 생성된 ID와 시간을 담은 DTO를 반환하게 수정하는 것이 좋습니다.
        ChatMessageDTO savedDto = chatService.saveMessage(
                messageDto.getChatRoomId(),
                messageDto.getSenderId(),
                messageDto.getMessage(),
                messageDto.getChatType(),
                messageDto.getFileUrl()
        );

        // 3. 구독자들에게 전송 (가장 중요한 부분)
        // /sub/chat/room/{id}를 구독 중인 모든 클라이언트(나+상대방)에게 전달
        messagingTemplate.convertAndSend("/sub/chat/room/" + savedDto.getChatRoomId(), savedDto);
    }
}

