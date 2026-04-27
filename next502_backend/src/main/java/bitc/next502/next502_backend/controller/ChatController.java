package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.entity.ChatMessageEntity;
import bitc.next502.next502_backend.domain.entity.ChatRoomEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.service.ChatService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;


    @PostMapping("/room/{warehouseId}")
    public ResponseEntity<ChatRoomEntity> createRoom(
            @PathVariable("warehouseId") Long warehouseId,
            @AuthenticationPrincipal MemberEntity member) {

        // 서비스 메서드 파라미터명과 일치시킴
        return ResponseEntity.ok(chatService.createOrGetRoom(warehouseId, member));
    }

    // 2. 나의 채팅방 목록 조회
    @GetMapping("/rooms")
    public ResponseEntity<List<ChatRoomEntity>> getMyRooms(
            @AuthenticationPrincipal MemberEntity member) {
        return ResponseEntity.ok(chatService.getMyChatRooms(member));
    }

    // 3. 특정 채팅방의 메시지 내역 조회 (페이징/Slice 처리)
    @GetMapping("/room/{chatRoomId}/messages")
    public ResponseEntity<Slice<ChatMessageEntity>> getMessages(
            @PathVariable("chatRoomId") Long chatRoomId,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(chatService.getChatMessages(chatRoomId, pageable));
    }

    // 4. 읽음 처리
    @PatchMapping("/room/{chatRoomId}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable("chatRoomId") Long chatRoomId,
            @AuthenticationPrincipal MemberEntity member) {
        chatService.markMessagesAsRead(chatRoomId, member);
        return ResponseEntity.ok().build();
    }
}