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
import java.util.Map;
import java.util.HashMap;

import java.util.List;

@RestController
@RequestMapping("/chat")
@RequiredArgsConstructor
public class ChatController {

    private final ChatService chatService;

    // 1. 채팅방 생성 (이미 수정하신 대로 유지)
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

    // 2. 나의 채팅방 목록 조회 (DTO 리스트로 변환)
    @GetMapping("/rooms")
    public ResponseEntity<List<ChatRoomDTO>> getMyRooms(
            @AuthenticationPrincipal MemberEntity member) {
        List<ChatRoomEntity> rooms = chatService.getMyChatRooms(member);

        List<ChatRoomDTO> response = rooms.stream().map(room -> {
            // 내가 구매자(Member)면 상대방은 판매자(Provider), 반대면 구매자(Member)
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

    // 3. 특정 채팅방의 메시지 내역 조회 (Slice<ChatMessageDTO>로 변환)
    @GetMapping("/room/{chatRoomId}/messages")
    public ResponseEntity<Slice<ChatMessageDTO>> getMessages(
            @PathVariable("chatRoomId") Long chatRoomId,
            @PageableDefault(size = 20) Pageable pageable) {

        Slice<ChatMessageEntity> messages = chatService.getChatMessages(chatRoomId, pageable);

        // 메시지 엔티티를 DTO로 변환 (Proxy 에러 원천 차단)
        Slice<ChatMessageDTO> response = messages.map(msg -> ChatMessageDTO.builder()
                .id(msg.getId())
                .chatRoomId(chatRoomId)
                .senderId(msg.getSender().getId())
                .senderNick(msg.getSender().getUserNick())
                .message(msg.getMessage())
                .chatType(msg.getChatType())
                .fileUrl(msg.getFileUrl())
                .createDate(msg.getCreateDate())
                .isReadYn(msg.getIsReadYn())
                .build());

        return ResponseEntity.ok(response);
    }

    // 4. 읽음 처리 (기존 유지)
    @PatchMapping("/room/{chatRoomId}/read")
    public ResponseEntity<Void> markAsRead(
            @PathVariable("chatRoomId") Long chatRoomId,
            @AuthenticationPrincipal MemberEntity member) {
        chatService.markMessagesAsRead(chatRoomId, member);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadFile(@RequestParam("file") MultipartFile file) {
        // 1. ChatService에 파일 저장 로직을 만들거나, 여기서 직접 처리
        // 지금은 예시로 ChatService에 uploadImage 메서드가 있다고 가정합니다.
        String imageUrl = chatService.uploadImage(file);

        // 2. Flutter에서 json.decode(response.body)['url'] 로 꺼낼 수 있게 반환
        Map<String, String> response = new HashMap<>();
        response.put("url", imageUrl);

        return ResponseEntity.ok(response);
    }
}