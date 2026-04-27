package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList; // 1. 추가
import java.util.List;

@Entity
@Table(name = "warehouses")
@Getter
@Setter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class WarehouseEntity extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long warehouseSeq;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_seq", nullable = false)
    private MemberEntity member;

    private String name;
    private String address;
    private Double totalArea;
    private String sizeRank;

    // 1:1 관계 - 상세 정보
    @OneToOne(mappedBy = "warehouse", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private WarehouseDetailEntity detail;

    // 1:N 관계 - 이미지 목록
    @Builder.Default // 2. 빌더 사용 시 초기값 유지를 위해 추가
    @OneToMany(mappedBy = "warehouse", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<WarehouseImageEntity> images = new ArrayList<>();

}
