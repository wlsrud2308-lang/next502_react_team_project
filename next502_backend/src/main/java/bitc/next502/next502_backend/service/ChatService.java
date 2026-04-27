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
    public ChatRoomEntity createOrGetRoom(Long warehouseId, MemberEntity buyer) {
        // 1-1. 해당 창고 정보 가져오기 (warehouseSeq -> warehouseId)
        WarehouseEntity warehouse = warehouseRepository.findById(warehouseId)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 창고입니다."));

        return chatRoomRepository.findExistRoom(warehouseId, buyer.getId())
                .orElseGet(() -> {
                    // 없으면 새로 생성
                    ChatRoomEntity newRoom = ChatRoomEntity.builder()
                            .buyer(buyer)
                            .provider(warehouse.getMember())
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
        return chatRoomRepository.findAllMyRooms(member);
    }

    /**
     * 3. 채팅 내역 조회 (페이징)
     */
    public Slice<ChatMessageEntity> getChatMessages(Long chatRoomId, Pageable pageable) {

        return chatMessageRepository.findByChatRoomIdOrderByIdDesc(chatRoomId, pageable);
    }

    /**
     * 4. 읽음 처리
     */
    @Transactional
    public void markMessagesAsRead(Long chatRoomId, MemberEntity member) {
        // member.getUserSeq() -> member.getId()
        chatMessageRepository.markAsRead(chatRoomId, member.getId());
    }
    @Transactional
    public ChatMessageEntity saveMessage(Long roomId, Long senderSeq, String content, ChatType type, String fileUrl) {
        // 방 정보와 보낸 사람 정보 조회
        ChatRoomEntity room = chatRoomRepository.findById(roomId)
                .orElseThrow(() -> new IllegalArgumentException("채팅방을 찾을 수 없습니다."));

        MemberEntity sender = memberRepository.findById(senderSeq)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 사용자입니다."));

        ChatMessageEntity message = ChatMessageEntity.builder()
                .chatRoom(room)
                .sender(sender)
                .message(content)
                .chatType(type)
                .fileUrl(fileUrl) // 사진 전송 시 사용
                .isReadYn("N")    // 초기값은 안읽음
                .build();

        return chatMessageRepository.save(message);
    }
}