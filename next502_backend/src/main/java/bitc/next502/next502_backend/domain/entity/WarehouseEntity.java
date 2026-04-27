package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "t_warehouse") // DB 테이블명에 맞춰 확인 (기존 warehouses에서 t_warehouse로 수정
@Getter
@Setter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class WarehouseEntity extends BaseTimeEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id")
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "user_id", nullable = false)
    private MemberEntity member;

    private String name;
    private String address;
    private Double totalArea;
    private String sizeRank;

    // 1:1 관계 - 상세 정보
    @OneToOne(mappedBy = "warehouse", cascade = CascadeType.ALL, fetch = FetchType.LAZY)
    private WarehouseDetailEntity detail;

    // 1:N 관계 - 이미지 목록
    @Builder.Default
    @OneToMany(mappedBy = "warehouse", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<WarehouseImageEntity> images = new ArrayList<>();

}