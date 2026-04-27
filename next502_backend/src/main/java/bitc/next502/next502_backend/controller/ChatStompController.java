package bitc.next502.next502_backend.controller;

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

    // 클라이언트가 /pub/chat/message 로 메시지를 보내면 실행됨
    @MessageMapping("/chat/message")
    public void message(ChatMessageEntity message) {
        // 1. 메시지 타입에 따른 처리 (입장 시 알림 등)
        if (ChatType.SYSTEM.equals(message.getChatType())) {
            message.setContent(message.getSender().getUserNick() + "님이 입장하셨습니다.");
        }

        // 2. DB에 메시지 저장 (ChatService에 저장 로직을 추가해야 함)
        // chatService.saveMessage(message);

        // 3. 해당 방을 구독 중인 사람들에게 메시지 전달 (/sub/chat/room/{roomId})
        messagingTemplate.convertAndSend("/sub/chat/room/" + message.getChatRoom().getChatRoomSeq(), message);
    }
}
