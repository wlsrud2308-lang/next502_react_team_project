package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.dto.WarehouseDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseDetailEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.repository.WarehouseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional; // Spring용으로 변경

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WarehouseService {

    private final WarehouseRepository warehouseRepository;

    // 1. 검색 결과를 DTO로 변환하여 반환 (플러터 연동 시 순환 참조 방지)
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

    // 3. 창고 및 상세 정보 동시 저장
    @Transactional
    public void insertWarehouse(WarehouseDTO dto, MemberEntity member) {
        // 창고 기본 정보 생성
        WarehouseEntity warehouse = WarehouseEntity.builder()
                .name(dto.getName())
                .address(dto.getAddress())
                .totalArea(dto.getTotalArea() != null ? Double.parseDouble(dto.getTotalArea()) : 0.0)
                .sizeRank(dto.getSizeRank())
                .member(member)
                .build();

        // 창고 상세 정보 생성 및 연관 관계 설정
        WarehouseDetailEntity detail = WarehouseDetailEntity.builder()
                .storageType(dto.getStorageType())
                .operationStructure(dto.getOperationStructure())
                .description(dto.getDescription())
                .amenities(dto.getAmenities())
                .warehouse(warehouse) // 1:1 매핑
                .build();

        // WarehouseEntity에 detail 주입 (CascadeType.ALL 설정으로 함께 저장됨)
        warehouse.setDetail(detail);

        warehouseRepository.save(warehouse);
    }
    // 찜하기 기능을 위해 Entity 객체를 직접 반환하는 메서드
    public WarehouseEntity getWarehouseEntity(Long id) {
        return warehouseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다. id: " + id));
    }

    // Entity -> DTO 변환 편의 메서드
    private WarehouseDTO convertToDTO(WarehouseEntity entity) {
        WarehouseDTO dto = WarehouseDTO.builder()
                .warehouseId(entity.getWarehouse_id())
                .name(entity.getName())
                .address(entity.getAddress())
                .totalArea(String.valueOf(entity.getTotalArea()))
                .sizeRank(entity.getSizeRank())
                .build();

        if (entity.getDetail() != null) {
            dto.setStorageType(entity.getDetail().getStorageType());
            dto.setOperationStructure(entity.getDetail().getOperationStructure());
            dto.setDescription(entity.getDetail().getDescription());
            dto.setAmenities(entity.getDetail().getAmenities());
        }
        return dto;
    }
}
