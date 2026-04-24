package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "chat_rooms")
@Getter
@Setter // 값 변경을 위해 추가
@NoArgsConstructor(access = AccessLevel.PROTECTED) // 1. JPA 필수 생성자
@AllArgsConstructor // 2. Builder를 위한 전체 생성자
@Builder // 3. 빌더 패턴 사용
public class ChatRoomEntity extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long chatRoomSeq;

    // 구매자 (MemberEntity가 있어야 함)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_user_seq", nullable = false)
    private MemberEntity buyer;

    // 판매자/임대인
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "provider_user_seq", nullable = false)
    private MemberEntity provider;

    // 어떤 창고에 대한 채팅인지
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_seq", nullable = false)
    private WarehouseEntity warehouse; // 프로젝트의 창고 엔티티명 확인!

    @Column(length = 20)
    private String status; // 예: OPEN, CLOSED

}
