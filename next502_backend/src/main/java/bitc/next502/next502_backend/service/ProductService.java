package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.dto.ProductDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.repository.ProductRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProductService {

    private final ProductRepository productRepository;

    public List<WarehouseEntity> searchProducts(String addr, String op, String wh, String name) {

        String address = (addr == null || addr.trim().isEmpty()) ? null : addr;
        String operation = (op == null || op.trim().isEmpty()) ? null : op;
        String warehouse = (wh == null || wh.trim().isEmpty()) ? null : wh;
        String productName = (name == null || name.trim().isEmpty()) ? null : name;

        return productRepository.searchProducts(address, operation, warehouse, productName);
    }

    // 창고 전체 목록 조회
    public List<WarehouseEntity> getAllProducts() {
        return productRepository.findAll();
    }

    // 특정 창고 상세 조회
    public WarehouseEntity getProductDetail(Long productId) {
        return productRepository.findById(productId)
                .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다."));
    }

    @Transactional
    public void insertProduct(ProductDTO dto, MemberEntity member) {
        WarehouseEntity product = WarehouseEntity.builder()
                .productName(dto.getProductName())
                .address(dto.getAddress())
                .contact(dto.getContact())
                .warehouseType(dto.getWarehouseType())
                .operationType(dto.getOperationType())
                .businessName(dto.getBusinessName())
                .businessAddress(dto.getBusinessAddress())
                .facilities(dto.getFacilities())
                .totalArea(dto.getTotalArea())
                .member(member) // 현재 로그인한 사용자 정보 연결
                .build();

        productRepository.save(product);
    }
}