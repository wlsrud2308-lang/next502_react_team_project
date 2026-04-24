package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chat_messages")
@Getter
@Setter // 필요시 추가
@NoArgsConstructor(access = AccessLevel.PROTECTED) // 1. JPA용 기본 생성자
@AllArgsConstructor // 2. 빌더용 전체 생성자
@Builder
public class ChatMessageEntity extends BaseTimeEntity { // 3. 상속 추가

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long messageSeq;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chat_room_seq", nullable = false)
    private ChatRoomEntity chatRoom;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_user_seq", nullable = false)
    private MemberEntity sender;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String content;

    @Builder.Default
    @Column(columnDefinition = "CHAR(1) DEFAULT 'N'")
    private String isReadYn = "N";
}

