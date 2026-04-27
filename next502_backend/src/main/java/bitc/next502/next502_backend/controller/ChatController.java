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

    // 1. 채팅방 생성 (창고 상세페이지에서 '문의하기' 클릭 시)
    @PostMapping("/room/{warehouseSeq}")
    public ResponseEntity<ChatRoomEntity> createRoom(
            @PathVariable Long warehouseSeq,
            @AuthenticationPrincipal MemberEntity member) {

        // 구매자(member)와 창고 번호를 넘겨 채팅방 생성 혹은 기존 방 반환
        return ResponseEntity.ok(chatService.createOrGetRoom(warehouseSeq, member));
    }

    // 2. 나의 채팅방 목록 조회
    @GetMapping("/rooms")
    public ResponseEntity<List<ChatRoomEntity>> getMyRooms(
            @AuthenticationPrincipal MemberEntity member) {
        return ResponseEntity.ok(chatService.getMyChatRooms(member));
    }

    // 3. 특정 채팅방의 메시지 내역 조회 (페이징/Slice 처리)
    @GetMapping("/room/{chatRoomSeq}/messages")
    public ResponseEntity<Slice<ChatMessageEntity>> getMessages(
            @PathVariable Long chatRoomSeq,
            @PageableDefault(size = 20) Pageable pageable) {
        return ResponseEntity.ok(chatService.getChatMessages(chatRoomSeq, pageable));
    }

    // 4. 읽음 처리
    @PatchMapping("/room/{chatRoomSeq}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable Long chatRoomSeq,
            @AuthenticationPrincipal MemberEntity member) {
        chatService.markMessagesAsRead(chatRoomSeq, member);
        return ResponseEntity.ok().build();
    }
}