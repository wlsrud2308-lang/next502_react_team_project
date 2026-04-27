package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chat_rooms") // DB 테이블명
@Getter
@Setter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@Builder
public class ChatRoomEntity extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    // 구매자
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_id", nullable = false) // DB 컬럼명에 맞춰 수정 (보통 _id 권장)
    private MemberEntity buyer;

    // 판매자/임대인
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_id", nullable = false)
    private MemberEntity provider;

    // 어떤 창고에 대한 채팅인지
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_id", nullable = false)
    private WarehouseEntity warehouse;

    @Column(length = 20)
    private String status; // OPEN, CLOSED

}