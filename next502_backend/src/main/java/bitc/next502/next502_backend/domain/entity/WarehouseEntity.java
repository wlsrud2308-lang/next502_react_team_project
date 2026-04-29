package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "warehouses") // 테이블명 통합
@Getter
@Setter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class WarehouseEntity extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "warehouse_id")
    private Long warehouseId;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private MemberEntity member;

    @Column(nullable = false)
    private String name;        // 창고명

    @Column(nullable = false)
    private String address;     // 주소

    private Double latitude;    // 위도
    private Double longitude;   // 경도

    @Column(name = "total_area")
    private Double totalArea;   // 총 면적

    @Column(name = "occupied_area")
    private Double occupiedArea; // 현재 사용 중인 면적 (사용률 계산용)

    @Column(name = "size_rank")
    private String sizeRank;    // 규모 (L/M/S)

    // --- WarehouseDetail에서 옮겨온 상세 필드들 ---
    @Column(name = "storage_type")
    private String storageType;      // 보관 유형 (상온, 냉동 등)

    @Column(name = "operation_structure")
    private String operationStructure; // 운영 구조

    @Column(columnDefinition = "TEXT")
    private String description;      // 상세 설명

    private String amenities;        // 편의 시설

    @Column(name = "rep_image_url")
    private String repImageUrl;      // 리스트 출력용 대표 이미지 URL

    // --- 연관 관계 ---
    // 1:N 관계 - 이미지 목록 (상세 페이지용 다중 이미지)
    @Builder.Default
    @OneToMany(mappedBy = "warehouse", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<WarehouseImageEntity> images = new ArrayList<>();

    // --- 비즈니스 로직 (도메인 모델 패턴) ---
    /**
     * 사용률 계산 (리액트 ProgressBar 연동용)
     */
    public int calculateUsageRate() {
        if (totalArea == null || totalArea <= 0 || occupiedArea == null) {
            return 0;
        }
        return (int) Math.round((occupiedArea / totalArea) * 100);
    }
}