package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chat_messages")
@Getter
@Setter // 1. 이 어노테이션이 있어야 setMessage()가 생성됩니다.
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class ChatMessageEntity extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id") // 2. 다른 엔티티와 통일 (messageSeq -> id)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "chat_room_id", nullable = false) // 3. 외래키 명칭 통일
    private ChatRoomEntity chatRoom;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "sender_id", nullable = false) // 4. 외래키 명칭 통일
    private MemberEntity sender;

    @Column(name = "message", columnDefinition = "TEXT") //
    private String message;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private ChatType chatType;

    @Column(length = 500)
    private String fileUrl;

    private Integer duration;

    @Builder.Default
    @Column(name = "is_read_yn", length = 1)
    private String isReadYn = "N";

    @Builder.Default
    @Column(name = "is_deleted_yn", length = 1)
    private String isDeletedYn = "N";
}