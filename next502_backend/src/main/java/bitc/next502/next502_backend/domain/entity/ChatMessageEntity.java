package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chat_messages")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class ChatMessageEntity extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long messageSeq;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chat_room_seq", nullable = false)
    private ChatRoomEntity chatRoom;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_user_seq", nullable = false)
    private MemberEntity sender;

    @Column(columnDefinition = "TEXT")
    private String content;

    @Enumerated(EnumType.STRING) // 2. Enum 타입 필수 설정
    @Column(nullable = false, length = 20)
    private ChatType chatType;

    @Column(length = 500)
    private String fileUrl;

    private Integer duration;

    @Builder.Default
    @Column(name = "is_read_yn", columnDefinition = "CHAR(1) DEFAULT 'N'")
    private String isReadYn = "N";

    @Builder.Default
    @Column(name = "is_deleted_yn", columnDefinition = "CHAR(1) DEFAULT 'N'")
    private String isDeletedYn = "N";
}

