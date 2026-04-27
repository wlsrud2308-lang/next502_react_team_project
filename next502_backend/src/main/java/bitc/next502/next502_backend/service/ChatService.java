package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.entity.ChatMessageEntity;
import bitc.next502.next502_backend.domain.entity.ChatRoomEntity;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.repository.ChatMessageRepository;
import bitc.next502.next502_backend.domain.repository.ChatRoomRepository;
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

    /**
     * 1. 채팅방 생성 또는 기존 방 조회
     * 창고 상세페이지에서 '문의하기' 클릭 시 동작
     */
    @Transactional
    public ChatRoomEntity createOrGetRoom(Long warehouseSeq, MemberEntity buyer) {
        // 1-1. 해당 창고 정보 가져오기
        WarehouseEntity warehouse = warehouseRepository.findById(warehouseSeq)
                .orElseThrow(() -> new IllegalArgumentException("존재하지 않는 창고입니다."));

        // 1-2. 이미 해당 유저(구매자)와 해당 창고에 대한 방이 있는지 확인
        return chatRoomRepository.findExistRoom(warehouseSeq, buyer.getUserSeq())
                .orElseGet(() -> {
                    // 없으면 새로 생성
                    ChatRoomEntity newRoom = ChatRoomEntity.builder()
                            .buyer(buyer)
                            .provider(warehouse.getMember()) // 창고 주인(판매자)
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
        // 내가 구매자이거나 판매자인 모든 방을 가져옴
        return chatRoomRepository.findAllMyRooms(member);
    }

    /**
     * 3. 채팅 내역 조회 (페이징)
     */
    public Slice<ChatMessageEntity> getChatMessages(Long chatRoomSeq, Pageable pageable) {
        return chatMessageRepository.findByChatRoomChatRoomSeqOrderByMessageSeqDesc(chatRoomSeq, pageable);
    }

    /**
     * 4. 읽음 처리
     */
    @Transactional
    public void markMessagesAsRead(Long chatRoomSeq, MemberEntity member) {
        // 본인이 보낸 거 말고, 상대방이 보낸 메시지만 'Y'로 변경
        chatMessageRepository.markAsRead(chatRoomSeq, member.getUserSeq());
    }
}