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

    @MessageMapping("/chat/message")
    public void message(ChatMessageEntity message) {
        if (ChatType.SYSTEM.equals(message.getChatType())) {
            message.setMessage(message.getSender().getUserNick() + "님이 입장하셨습니다.");
        }

        chatService.saveMessage(
                message.getChatRoom().getChatRoomId(),
                message.getSender().getId(),
                message.getMessage(),
                message.getChatType(),
                message.getFileUrl()
        );

        messagingTemplate.convertAndSend("/sub/chat/room/" + message.getChatRoom().getChatRoomId(), message);
    }
}
