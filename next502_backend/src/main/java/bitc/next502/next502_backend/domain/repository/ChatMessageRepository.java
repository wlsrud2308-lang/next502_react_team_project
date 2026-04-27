package bitc.next502.next502_backend.domain.repository;

import bitc.next502.next502_backend.domain.entity.ChatMessageEntity;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Slice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface ChatMessageRepository extends JpaRepository<ChatMessageEntity, Long> {


    Slice<ChatMessageEntity> findByChatRoomIdOrderByIdDesc(Long chatRoomId, Pageable pageable);


    @Modifying(clearAutomatically = true)
    @Query("UPDATE ChatMessageEntity m SET m.isReadYn = 'Y' " +
            "WHERE m.chatRoom.id = :roomId " +
            "AND m.sender.id != :userId " +
            "AND m.isReadYn = 'N'")
    int markAsRead(@Param("roomId") Long roomId, @Param("userId") Long userId);
}