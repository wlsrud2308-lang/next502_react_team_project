package bitc.next502.next502_backend.domain.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "t_map_info")
@Getter
@Setter
@Builder
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class MapEntity extends BaseTimeEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Double latitude;  // 위도
    private Double longitude; // 경도

    @OneToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "product_id") // 어떤 창고의 좌표인지
    private WarehouseEntity product;
    }