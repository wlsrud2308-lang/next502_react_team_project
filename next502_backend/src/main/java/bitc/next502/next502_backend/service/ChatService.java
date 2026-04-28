package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.entity.*;
import bitc.next502.next502_backend.domain.repository.ChatMessageRepository;
import bitc.next502.next502_backend.domain.repository.ChatRoomRepository;
import bitc.next502.next502_backend.domain.repository.MemberRepository;
import bitc.next502.next502_backend.domain.repository.WarehouseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ChatService {

    private final ChatRoomRepository chatRoomRepository;
    private final ChatMessageRepository chatMessageRepository;
    private final WarehouseRepository warehouseRepository;
    private final MemberRepository memberRepository;

    /**
     * 1. 채팅방 생성 또는 기존 방 조회
     */
    @Transactional
    public ChatRoomEntity createOrGetRoom(Long warehouseId, MemberEntity currentUser) {
        // 창고 정보 조회
        WarehouseEntity warehouse = warehouseRepository.findById(warehouseId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 창고입니다."));

        // 본인 창고에는 채팅 불가 로직 추가 (선택사항이나 권장)
        if (warehouse.getMember().getId().equals(currentUser.getId())) {
            throw new IllegalStateException("본인의 창고에는 상담을 신청할 수 없습니다.");
        }

        // [수정] ChatRoomEntity 필드명에 맞춰 조회 (buyer -> member)
        // 리포지토리의 findExistRoom 메서드 정의도 이에 맞춰져 있어야 합니다.
        return chatRoomRepository.findExistRoom(warehouseId, currentUser.getId())
                .orElseGet(() -> {
                    ChatRoomEntity newRoom = ChatRoomEntity.builder()
                            .member(currentUser) // buyer -> member로 변경
                            .provider(warehouse.getMember()) // 창고 주인
                            .warehouse(warehouse)
                            .status("OPEN")
                            .build();
                    return chatRoomRepository.save(newRoom);
                });
    }

    /**
     * 2. 로그인한 유저의 채팅방 목록 조회
     */
    public List<ChatRoomEntity> getMyChatRooms(MemberEntity member) {
        // 리포지토리에서 MemberEntity의 ID를 사용하여 내가 구매자거나 판매자인 방을 모두 찾음
        return chatRoomRepository.findAllMyRooms(member);
    }

    /**
     * 3. 채팅 내역 조회 (페이징)
     */
    public Slice<ChatMessageEntity> getChatMessages(Long chatRoomId, Pageable pageable) {
        // ChatMessageEntity에 chatRoomId 필드가 없다면
        // findByChatRoom_ChatRoomIdOrderByIdDesc 처럼 연관관계 경로를 명시해야 할 수 있습니다.
        return chatMessageRepository.findByChatRoom_ChatRoomIdOrderByIdDesc(chatRoomId, pageable);
    }

    /**
     * 4. 읽음 처리
     */
    @Transactional
    public void markMessagesAsRead(Long chatRoomId, MemberEntity member) {
        chatMessageRepository.markAsRead(chatRoomId, member.getId());
    }

    /**
     * 5. 메시지 저장
     */
    @Transactional
    public ChatMessageEntity saveMessage(Long roomId, Long senderId, String content, ChatType type, String fileUrl) {
        ChatRoomEntity room = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방을 찾을 수 없습니다."));

        MemberEntity sender = memberRepository.findById(senderId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        ChatMessageEntity message = ChatMessageEntity.builder()
                .chatRoom(room)
                .sender(sender)
                .message(content)
                .chatType(type)
                .fileUrl(fileUrl)
                .isReadYn("N")
                .build();

        return chatMessageRepository.save(message);
    }
}
