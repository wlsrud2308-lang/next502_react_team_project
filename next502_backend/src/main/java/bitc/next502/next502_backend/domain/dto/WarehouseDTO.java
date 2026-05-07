package bitc.next502.next502_backend.domain.dto;

import lombok.*;
import java.util.List; // ★ List 임포트 추가

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WarehouseDTO {

    private Long warehouseId;
    private String name;
    private String address;

    private Double latitude;
    private Double longitude;

    private String totalArea;
    private Double occupiedArea;
    private Integer usageRate;

    private String sizeRank;
    private String repImageUrl;

    
    private List<String> imageUrls;

    private String storageType;
    private String operationStructure;
    private String description;
    private String amenities;

    private String contact;
}