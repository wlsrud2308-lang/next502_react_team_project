package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.dto.WarehouseDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseImageEntity;
import bitc.next502.next502_backend.domain.repository.WarehouseRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class WarehouseService {

    private final WarehouseRepository warehouseRepository;

    @Value("${upload.warehouse.path}")
    private String uploadPath;

    public List<WarehouseDTO> searchWarehouses(String addr, String size, String name) {
        String address = (addr == null || addr.trim().isEmpty()) ? null : addr;
        String sizeRank = (size == null || size.trim().isEmpty()) ? null : size;
        String warehouseName = (name == null || name.trim().isEmpty()) ? null : name;

        List<WarehouseEntity> entities = warehouseRepository.searchWarehouses(address, sizeRank, warehouseName);

        return entities.stream()
                .map(this::convertToDTO)
                .toList();
    }

    public WarehouseDTO getWarehouseDetail(Long id) {
        WarehouseEntity entity = warehouseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다."));
        return convertToDTO(entity);
    }


    @Transactional
    public Long insertWarehouse(WarehouseDTO dto, List<MultipartFile> images, MemberEntity member) throws Exception {
        // 1. 업로드 디렉토리 생성
        Path uploadDir = Paths.get(uploadPath);
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
            log.info("[Warehouse] 업로드 디렉토리 생성: {}", uploadDir.toAbsolutePath());
        }

        // 2. WarehouseEntity 생성
        WarehouseEntity warehouse = WarehouseEntity.builder()
                .name(dto.getName())
                .address(dto.getAddress())
                .totalArea(dto.getTotalArea() != null && !dto.getTotalArea().isEmpty()
                        ? Double.parseDouble(dto.getTotalArea()) : 0.0)
                .occupiedArea(0.0)
                .sizeRank(dto.getSizeRank())
                .latitude(dto.getLatitude())
                .longitude(dto.getLongitude())
                .storageType(dto.getStorageType())
                .operationStructure(dto.getOperationStructure())
                .description(dto.getDescription())
                .amenities(dto.getAmenities())
                .member(member)
                .build();

        // 3. 이미지 파일 저장 + Entity 생성
        List<WarehouseImageEntity> imageEntities = new ArrayList<>();
        String repImageUrl = null;

        for (int i = 0; i < images.size(); i++) {
            MultipartFile file = images.get(i);
            if (file.isEmpty()) continue;

            // UUID + 원본 확장자로 파일명 생성
            String originalName = file.getOriginalFilename();
            String ext = (originalName != null && originalName.contains("."))
                    ? originalName.substring(originalName.lastIndexOf("."))
                    : ".jpg";
            String savedName = UUID.randomUUID() + ext;

            // 로컬 저장
            File destFile = new File(uploadPath, savedName);
            file.transferTo(destFile);

            // 클라이언트에서 접근할 URL 경로
            String imageUrl = "/uploads/warehouse/" + savedName;

            // 첫 번째 이미지를 대표로
            boolean isRep = (i == 0);
            if (isRep) {
                repImageUrl = imageUrl;
            }

            WarehouseImageEntity imageEntity = WarehouseImageEntity.builder()
                    .warehouse(warehouse)
                    .imageUrl(imageUrl)
                    .isRepresentativeYn(isRep ? "Y" : "N")
                    .sortOrder(i)
                    .build();

            imageEntities.add(imageEntity);
        }

        // 4. 대표 이미지 URL 설정 + 이미지 연결
        warehouse.setRepImageUrl(repImageUrl);
        warehouse.getImages().addAll(imageEntities);

        // 5. 저장
        WarehouseEntity saved = warehouseRepository.save(warehouse);
        log.info("[Warehouse] 등록 완료 - id: {}, 이미지 {}장", saved.getWarehouseId(), imageEntities.size());

        return saved.getWarehouseId();
    }

    public WarehouseEntity getWarehouseEntity(Long id) {
        return warehouseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다. id: " + id));
    }

    private WarehouseDTO convertToDTO(WarehouseEntity entity) {
        return WarehouseDTO.builder()
                .warehouseId(entity.getWarehouseId())
                .name(entity.getName())
                .address(entity.getAddress())
                .latitude(entity.getLatitude())
                .longitude(entity.getLongitude())
                .totalArea(String.valueOf(entity.getTotalArea()))
                .occupiedArea(entity.getOccupiedArea())
                .usageRate(entity.calculateUsageRate())
                .sizeRank(entity.getSizeRank())
                .storageType(entity.getStorageType())
                .operationStructure(entity.getOperationStructure())
                .description(entity.getDescription())
                .amenities(entity.getAmenities())
                .repImageUrl(entity.getRepImageUrl())
                .build();
    }
}