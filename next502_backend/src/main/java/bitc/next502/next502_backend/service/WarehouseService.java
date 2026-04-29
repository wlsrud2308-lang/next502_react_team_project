package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.dto.WarehouseDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.repository.WarehouseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WarehouseService {

    private final WarehouseRepository warehouseRepository;

    // 1. 검색 결과를 DTO로 변환하여 반환
    public List<WarehouseDTO> searchWarehouses(String addr, String size, String name) {
        String address = (addr == null || addr.trim().isEmpty()) ? null : addr;
        String sizeRank = (size == null || size.trim().isEmpty()) ? null : size;
        String warehouseName = (name == null || name.trim().isEmpty()) ? null : name;

        List<WarehouseEntity> entities = warehouseRepository.searchWarehouses(address, sizeRank, warehouseName);

        return entities.stream()
            .map(this::convertToDTO)
            .toList();
    }

    // 2. 창고 상세 조회 (DTO로 반환)
    public WarehouseDTO getWarehouseDetail(Long id) {
        WarehouseEntity entity = warehouseRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다."));
        return convertToDTO(entity);
    }

    // 3. 창고 저장 (상세 정보 통합 버전)
    @Transactional
    public void insertWarehouse(WarehouseDTO dto, MemberEntity member) {
        WarehouseEntity warehouse = WarehouseEntity.builder()
            .name(dto.getName())
            .address(dto.getAddress())
            // DTO가 String으로 온다면 Double로 변환
            .totalArea(dto.getTotalArea() != null ? Double.parseDouble(dto.getTotalArea()) : 0.0)
            .occupiedArea(0.0) // 초기 저장 시 사용 면적은 0으로 설정 (필요시 dto에서 받음)
            .sizeRank(dto.getSizeRank())
            .latitude(dto.getLatitude())  // 위도 추가
            .longitude(dto.getLongitude()) // 경도 추가
            .repImageUrl(dto.getRepImageUrl()) // 대표 이미지 추가
            .storageType(dto.getStorageType())
            .operationStructure(dto.getOperationStructure())
            .description(dto.getDescription())
            .amenities(dto.getAmenities())
            .member(member)
            .build();

        warehouseRepository.save(warehouse);
    }

    // 찜하기 기능을 위해 Entity 객체를 직접 반환하는 메서드
    public WarehouseEntity getWarehouseEntity(Long id) {
        return warehouseRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다. id: " + id));
    }

    // Entity -> DTO 변환 편의 메서드 (통합된 필드 반영)
    private WarehouseDTO convertToDTO(WarehouseEntity entity) {
        return WarehouseDTO.builder()
            .warehouseId(entity.getWarehouseId()) // 필드명 카멜케이스 적용 확인
            .name(entity.getName())
            .address(entity.getAddress())
            .latitude(entity.getLatitude())
            .longitude(entity.getLongitude())
            .totalArea(String.valueOf(entity.getTotalArea()))
            .occupiedArea(entity.getOccupiedArea())
            .usageRate(entity.calculateUsageRate()) // 엔티티의 계산 로직 활용
            .sizeRank(entity.getSizeRank())
            .storageType(entity.getStorageType())
            .operationStructure(entity.getOperationStructure())
            .description(entity.getDescription())
            .amenities(entity.getAmenities())
            .repImageUrl(entity.getRepImageUrl())
            .build();
    }
}