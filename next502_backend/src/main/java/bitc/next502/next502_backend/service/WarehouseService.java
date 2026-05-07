package bitc.next502.next502_backend.service;

import bitc.next502.next502_backend.domain.dto.WarehouseDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.Role; // Role 추가
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

    public WarehouseEntity getWarehouseEntity(Long id) {
        return warehouseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다. id: " + id));
    }

    public WarehouseDTO getWarehouseDetail(Long id) {
        WarehouseEntity entity = warehouseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다."));
        return convertToDTO(entity);
    }

    public List<WarehouseDTO> getMyWarehouseList(MemberEntity member) {
        List<WarehouseEntity> myWarehouses = warehouseRepository.findByMember(member);
        return myWarehouses.stream()
                .map(this::convertToDTO)
                .toList();
    }

    @Transactional
    public Long insertWarehouse(WarehouseDTO dto, List<MultipartFile> images, MemberEntity member) throws Exception {
        Path uploadDir = Paths.get(uploadPath);
        if (!Files.exists(uploadDir)) {
            Files.createDirectories(uploadDir);
        }

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

        List<WarehouseImageEntity> imageEntities = new ArrayList<>();
        String repImageUrl = null;

        for (int i = 0; i < images.size(); i++) {
            MultipartFile file = images.get(i);
            if (file.isEmpty()) continue;

            String savedName = UUID.randomUUID() + "_" + file.getOriginalFilename();
            File destFile = new File(uploadPath, savedName);
            file.transferTo(destFile);

            String imageUrl = "/uploads/warehouse/" + savedName;
            if (i == 0) repImageUrl = imageUrl;

            WarehouseImageEntity imageEntity = WarehouseImageEntity.builder()
                    .warehouse(warehouse)
                    .imageUrl(imageUrl)
                    .isRepresentativeYn(i == 0 ? "Y" : "N")
                    .sortOrder(i)
                    .build();
            imageEntities.add(imageEntity);
        }

        warehouse.setRepImageUrl(repImageUrl);
        warehouse.getImages().addAll(imageEntities);

        WarehouseEntity saved = warehouseRepository.save(warehouse);
        return saved.getWarehouseId();
    }

    @Transactional
    public void updateWarehouse(Long id, WarehouseDTO dto, List<MultipartFile> images) throws Exception {
        WarehouseEntity entity = warehouseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 창고를 찾을 수 없습니다."));

        entity.setName(dto.getName());
        entity.setAddress(dto.getAddress());
        entity.setTotalArea(dto.getTotalArea() != null && !dto.getTotalArea().isEmpty()
                ? Double.parseDouble(dto.getTotalArea()) : 0.0);
        entity.setSizeRank(dto.getSizeRank());
        entity.setStorageType(dto.getStorageType());
        entity.setOperationStructure(dto.getOperationStructure());
        entity.setDescription(dto.getDescription());
        entity.setAmenities(dto.getAmenities());

        if (images != null && !images.isEmpty() && !images.get(0).isEmpty()) {
            entity.getImages().clear();
            List<WarehouseImageEntity> newImageEntities = new ArrayList<>();
            String repImageUrl = null;

            for (int i = 0; i < images.size(); i++) {
                MultipartFile file = images.get(i);
                String savedName = UUID.randomUUID() + "_" + file.getOriginalFilename();
                File destFile = new File(uploadPath, savedName);
                file.transferTo(destFile);

                String imageUrl = "/uploads/warehouse/" + savedName;
                if (i == 0) repImageUrl = imageUrl;

                newImageEntities.add(WarehouseImageEntity.builder()
                        .warehouse(entity)
                        .imageUrl(imageUrl)
                        .isRepresentativeYn(i == 0 ? "Y" : "N")
                        .sortOrder(i)
                        .build());
            }
            entity.setRepImageUrl(repImageUrl);
            entity.getImages().addAll(newImageEntities);
        }
    }


    @Transactional
    public void deleteWarehouse(Long id, MemberEntity member) {

        WarehouseEntity warehouse = warehouseRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("해당 창고가 존재하지 않습니다. id: " + id));


        if (!warehouse.getMember().getId().equals(member.getId()) &&
                member.getRole() != Role.ROLE_ADMIN) {
            throw new RuntimeException("삭제 권한이 없습니다.");
        }


        warehouseRepository.delete(warehouse);
        log.info("[Warehouse] 삭제 성공 - id: {}, 삭제자: {}", id, member.getUsername());
    }

    private WarehouseDTO convertToDTO(WarehouseEntity entity) {
        List<String> imageUrlList = new ArrayList<>();
        if (entity.getImages() != null && !entity.getImages().isEmpty()) {
            imageUrlList = entity.getImages().stream()
                    .map(WarehouseImageEntity::getImageUrl)
                    .toList();
        }

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
                .imageUrls(imageUrlList)
                .build();
    }
}