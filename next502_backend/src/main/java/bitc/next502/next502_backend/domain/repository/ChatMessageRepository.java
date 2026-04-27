package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.ChatMessageEntity;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ChatMessageRepository extends JpaRepository<ChatMessageEntity, Long> {

    // 1. 특정 채팅방의 메시지 목록 조회 (무한 스크롤을 위해 Slice 사용)
    // 최신순으로 가져오기 위해 OrderByMessageSeqDesc 사용
    Slice<ChatMessageEntity> findByChatRoomChatRoomSeqOrderByMessageSeqDesc(Long chatRoomSeq, Pageable pageable);

    // 2. 읽음 처리 (벌크 업데이트)
    // 상대방이 보낸 메시지 중 아직 읽지 않은(N) 메시지를 모두 Y로 변경
    @Modifying(clearAutomatically = true)
    @Query("UPDATE ChatMessageEntity m SET m.isReadYn = 'Y' " +
            "WHERE m.chatRoom.chatRoomSeq = :roomSeq " +
            "AND m.sender.userSeq != :userSeq " +
            "AND m.isReadYn = 'N'")
    int markAsRead(@Param("roomSeq") Long roomSeq, @Param("userSeq") Long userSeq);
}