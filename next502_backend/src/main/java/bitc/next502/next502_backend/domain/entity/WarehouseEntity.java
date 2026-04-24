package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "t_product")
@Getter
@Setter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class WarehouseEntity extends BaseTimeEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long productId;

    @Column(nullable = false)
    private String productName;      // 창고명
    private String address;          // 창고 주소
    private String contact;          // 담당자 번호
    private String warehouseType;    // 창고 유형
    private String operationType;    // 운영구조
    private String businessName;     // 사업장명
    private String businessAddress;  // 사업장주소

    @Column(columnDefinition = "TEXT")
    private String facilities;       // 시설 및 서비스 상세

    private String totalArea;        // 총 창고 면적

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "member_id")  // 등록한 임대인
    private MemberEntity member;
}
