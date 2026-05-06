package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.ChatMessageDTO;
import bitc.next502.next502_backend.domain.dto.ChatRoomDTO;
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
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    // 1. 채팅방 생성 (MySQL 기반)
    @PostMapping("/room/{warehouseId}")
    public ResponseEntity<ChatRoomDTO> createRoom(
            @PathVariable("warehouseId") Long warehouseId,
            @AuthenticationPrincipal MemberEntity member) {

        ChatRoomEntity room = chatService.createOrGetRoom(warehouseId, member);
        ChatRoomDTO response = ChatRoomDTO.builder()
                .chatRoomId(room.getChatRoomId())
                .warehouseName(room.getWarehouse().getName())
                .build();
        return ResponseEntity.ok(response);
    }

    // 2. 나의 채팅방 목록 조회
    @GetMapping("/rooms")
    public ResponseEntity<List<ChatRoomDTO>> getMyRooms(
            @AuthenticationPrincipal MemberEntity member) {
        List<ChatRoomEntity> rooms = chatService.getMyChatRooms(member);

        List<ChatRoomDTO> response = rooms.stream().map(room -> {
            boolean isMember = room.getMember().getId().equals(member.getId());
            MemberEntity opponent = isMember ? room.getProvider() : room.getMember();

            return ChatRoomDTO.builder()
                    .chatRoomId(room.getChatRoomId())
                    .warehouseName(room.getWarehouse().getName())
                    .userid(opponent.getUserId())
                    .updateDate(room.getUpdateDate() != null ? room.getUpdateDate().toString() : "")
                    .build();
        }).toList();

        return ResponseEntity.ok(response);
    }

    // 3. 특정 채팅방의 과거 메시지 내역 조회 (Slice 처리)
    @GetMapping("/room/{chatRoomId}/messages")
    public ResponseEntity<Slice<ChatMessageDTO>> getMessages(
            @PathVariable("chatRoomId") Long chatRoomId,
            @PageableDefault(size = 20) Pageable pageable) {

        Slice<ChatMessageEntity> messages = chatService.getChatMessages(chatRoomId, pageable);

        // Entity -> DTO 변환 (LocalDateTime을 String으로 변환하여 오류 해결)
        Slice<ChatMessageDTO> response = messages.map(msg -> ChatMessageDTO.builder()
                .id(msg.getId())
                .chatRoomId(chatRoomId)
                .senderId(msg.getSender().getId())
                .senderNick(msg.getSender().getUserNick())
                .message(msg.getMessage())
                .chatType(msg.getChatType())
                .fileUrl(msg.getFileUrl())
                .createDate(msg.getCreateDate() != null ? msg.getCreateDate().toString() : "")
                .isReadYn(msg.getIsReadYn())
                .build());

        return ResponseEntity.ok(response);
    }

    // 4. 읽음 처리
    @PatchMapping("/room/{chatRoomId}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable("chatRoomId") Long chatRoomId,
            @AuthenticationPrincipal MemberEntity member) {
        chatService.markMessagesAsRead(chatRoomId, member);
        return ResponseEntity.ok().build();
    }

    // 5. 이미지 업로드 (플러터 연동용)
    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadFile(
            @RequestParam("file") MultipartFile file) {

        String imageUrl = chatService.uploadImage(file);

        Map<String, String> response = new HashMap<>();
        response.put("url", imageUrl);

        return ResponseEntity.ok(response);
    }

    // 6. [추가 추천] Firebase 커스텀 토큰 발급
    @GetMapping("/firebase-token")
    public ResponseEntity<Map<String, String>> getFirebaseToken(
            @AuthenticationPrincipal MemberEntity member) {

        String customToken = chatService.createFirebaseCustomToken(member.getUserId());

        Map<String, String> response = new HashMap<>();
        response.put("token", customToken);

        return ResponseEntity.ok(response);
    }
}

