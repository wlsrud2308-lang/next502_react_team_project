package bitc.next502.next502_backend.domain.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WarehouseDTO {

    private Long warehouseId;     // 창고 고유 번호
    private String name;           // 창고명 (기존 productName)
    private String address;        // 창고 주소
    private String totalArea;      // 총 면적 (Service에서 Double로 변환)
    private String sizeRank;       // 창고 규모 (기존 warehouseType)

    // 상세 정보 (WarehouseDetail 관련)
    private String storageType;      // 보관 유형 (상온, 냉동 등)
    private String operationStructure; // 운영 구조
    private String description;      // 상세 설명
    private String amenities;        // 편의 시설

    // 담당자 정보
    private String contact;          // 연락처
}
