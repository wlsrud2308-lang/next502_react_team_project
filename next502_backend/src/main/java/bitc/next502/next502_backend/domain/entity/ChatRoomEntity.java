package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chat_rooms")
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class ChatRoomEntity extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "chat_room_id")
    private Long chatRoomId;

    // 구매자(일반 회원) -> Role.ROLE_MEMBER 인 사람
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id", nullable = false) // buyer_id 대신 member_id로 수정
    private MemberEntity member;

    // 판매자(임대인) -> Role.ROLE_PROVIDER 인 사람
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    private MemberEntity provider;

    // 어떤 창고에 대한 채팅인지
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false)
    private WarehouseEntity warehouse;

    @Builder.Default
    @Column(length = 20)
    private String status = "OPEN";
}