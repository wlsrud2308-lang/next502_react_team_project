package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.ChatRoomDTO;
import bitc.next502.next502_backend.domain.entity.ChatRoomEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.service.ChatService;
import lombok.RequiredArgsConstructor;
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

    // 1. 채팅방 생성
    // (채팅 목록을 RDB에서 긁어오거나 트래킹하기 위해 기존 데이터베이스 방 생성 로직 유지)
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
    // (대화 목록 방의 존재 여부는 기존 RDB 데이터를 사용하여 빠르게 리턴)
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

<<<<<<< HEAD
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

=======
    // 3. 이미지 업로드 (플러터 연동 규격)
    // 플러터 앱이 쏜 파일을 물리 폴더에 저장하고 URL만 가로채 JSON 객체로 반환합니다.
>>>>>>> csy/firebase_chat_server
    @PostMapping("/upload")
    public ResponseEntity<Map<String, String>> uploadFile(
            @RequestParam("file") MultipartFile file) {

        // ChatService의 물리 파일 저장 로직 호출 (UUID 처리 필수)
        String imageUrl = chatService.uploadImage(file);

        Map<String, String> response = new HashMap<>();
        response.put("url", imageUrl); // 플러터 json.decode(response.body)['url'] 규격

        return ResponseEntity.ok(response);
    }
}
