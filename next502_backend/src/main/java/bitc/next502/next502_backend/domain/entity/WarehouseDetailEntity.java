package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "warehouse_details")
@Getter
@Setter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
@ToString(exclude = "warehouse") // 중요: 양방향 참조 시 무한 루프 방지
public class WarehouseDetailEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long warehouseDetailSeq;

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_seq", nullable = false) // FK 설정
    private WarehouseEntity warehouse;

    private String storageType;      // 보관 유형
    private String operationStructure; // 운영 구조

    @Column(columnDefinition = "TEXT")
    private String description;      // 상세 설명
    private String amenities;        // 편의 시설

    // 연관 관계 편의 메서드 (객체 상태를 안전하게 유지하기 위함)
    public void setWarehouse(WarehouseEntity warehouse) {
        this.warehouse = warehouse;
        if (warehouse.getDetail() != this) {
            warehouse.setDetail(this);
        }
    }
}