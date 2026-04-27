package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "warehouse_images")
@Getter
@Setter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class WarehouseImageEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long warehouseImageSeq;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "warehouse_seq", nullable = false) // 어떤 창고의 이미지인지
    private WarehouseEntity warehouse;

    @Column(nullable = false, length = 500)
    private String imageUrl; // S3 또는 서버 저장 경로

    @Builder.Default
    @Column(columnDefinition = "CHAR(1) DEFAULT 'N'")
    private String isRepresentativeYn = "N"; // 대표 이미지 여부 (Y/N)

    private Integer sortOrder; // 이미지 출력 순서
}