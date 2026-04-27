package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.dto.WarehouseDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
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

    // 다중 조건 검색
    public List<WarehouseEntity> searchWarehouses(String addr, String size, String name) {
        String address = (addr == null || addr.trim().isEmpty()) ? null : addr;
        String sizeRank = (size == null || size.trim().isEmpty()) ? null : size;
        String warehouseName = (name == null || name.trim().isEmpty()) ? null : name;

        return warehouseRepository.searchWarehouses(address, sizeRank, warehouseName);
    }

    // 창고 전체 목록 조회
    public List<WarehouseEntity> getAllWarehouses() {
        return warehouseRepository.findAll();
    }

    // 특정 창고 상세 조회
    public WarehouseEntity getWarehouseDetail(Long warehouseSeq) {
        return warehouseRepository.findById(warehouseSeq)
                .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다."));
    }

    @Transactional
    public void insertWarehouse(WarehouseDTO dto, MemberEntity member) {
        WarehouseEntity warehouse = WarehouseEntity.builder()
                .name(dto.getName()) // dto.getProductName() -> dto.getName()
                .address(dto.getAddress())
                .totalArea(dto.getTotalArea() != null ? Double.parseDouble(dto.getTotalArea()) : 0.0)
                .sizeRank(dto.getSizeRank()) // dto.getWarehouseType() -> dto.getSizeRank()
                .member(member)
                .build();

        warehouseRepository.save(warehouse);
    }
}
