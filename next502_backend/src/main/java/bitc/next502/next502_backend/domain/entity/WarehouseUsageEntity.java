package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "t_storage_usage")
@Getter @Setter @Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class WarehouseUsageEntity extends BaseTimeEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long usageId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id")
    private WarehouseEntity product;

    private Double currentUsedArea;  // 현재 사용 중인 면적
    private Double availableArea;    // 현재 가용 면적 (남은 공간)

    @Column(length = 100)
    private String statusNote;       // 상태 비고 (예: "성수기 물량 증가", "일부 구역 공사 중")

    // 사용률 계산 로직 (예: 75%)
    public Integer getUsageRate(Double total) {
        if (total == null || total == 0) return 0;
        return (int) ((this.currentUsedArea / total) * 100);
    }
}
