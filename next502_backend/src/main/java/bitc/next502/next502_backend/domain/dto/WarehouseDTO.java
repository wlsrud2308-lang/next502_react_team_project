package bitc.next502.next502_backend.domain.dto;

import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WarehouseDTO {

    private Long warehouseId;      // 창고 고유 번호
    private String name;           // 창고명
    private String address;        // 창고 주소

    // 지도 연동을 위한 좌표
    private Double latitude;       // 위도
    private Double longitude;      // 경도

    private String totalArea;      // 총 면적 (단위: ㎡)
    private Double occupiedArea;   // 사용 중인 면적
    private Integer usageRate;     // 사용률 (0~100, 계산된 결과값)

    private String sizeRank;       // 창고 규모 (L/M/S)
    private String repImageUrl;    // 리스트 출력용 대표 이미지 URL

    // 상세 정보 (통합된 필드)
    private String storageType;      // 보관 유형 (상온, 냉동 등)
    private String operationStructure; // 운영 구조
    private String description;      // 상세 설명
    private String amenities;        // 편의 시설

    // 담당자 정보
    private String contact;          // 연락처
}