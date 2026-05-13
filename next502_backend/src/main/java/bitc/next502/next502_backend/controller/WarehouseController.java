package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.WarehouseDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.Role;
import bitc.next502.next502_backend.service.WarehouseService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;

@Slf4j
@RestController
@RequestMapping("/warehouse")
@RequiredArgsConstructor
public class WarehouseController {

    private final WarehouseService warehouseService;

    /**
     * 통합 검색 엔드포인트
     * 파라미터가 모두 비어있으면 전체 목록을 반환합니다.
     */
    @GetMapping("/search")
    public ResponseEntity<List<WarehouseDTO>> search(
        @RequestParam(value = "location", required = false) String location,
        @RequestParam(value = "size", required = false) String size,
        @RequestParam(value = "name", required = false) String name,
        @RequestParam(value = "keyword", required = false) String keyword,
        @RequestParam(value = "storageType", required = false) String storageType) {

        // 1. 모든 검색 조건이 없는 경우 (검색어 미입력 시 전체 목록 출력)
        if (isAllEmpty(location, size, name, keyword, storageType)) {
            log.info("[API] 모든 검색 파라미터가 비어있음 -> 전체 창고 목록 반환");
            // 서비스에 전체 목록 조회 메서드가 없다면 findAll() 성격의 메서드를 호출하세요.
            return ResponseEntity.ok(warehouseService.getAllWarehouses());
        }

        // 2. 플러터용 파라미터(keyword 또는 storageType)가 들어온 경우
        if ((keyword != null && !keyword.trim().isEmpty()) ||
            (storageType != null && !storageType.trim().isEmpty())) {
            log.info("[API] 플러터 통합 검색 - keyword: {}, type: {}", keyword, storageType);
            return ResponseEntity.ok(warehouseService.searchWarehousesUnified(keyword, storageType));
        }

        // 3. 그 외에는 기존 리액트용 상세 검색 로직 수행
        log.info("[API] 리액트 상세 검색 - location: {}, size: {}, name: {}", location, size, name);
        return ResponseEntity.ok(warehouseService.searchWarehouses(location, size, name));
    }

    /**
     * 모든 파라미터가 null이거나 빈 문자열인지 체크하는 헬퍼 메서드
     */
    private boolean isAllEmpty(String... params) {
        for (String p : params) {
            if (p != null && !p.trim().isEmpty()) {
                return false;
            }
        }
        return true;
    }

    @GetMapping("/{id}")
    public ResponseEntity<WarehouseDTO> getWarehouseDetail(@PathVariable("id") Long id) {
        WarehouseDTO warehouseDTO = warehouseService.getWarehouseDetail(id);
        return ResponseEntity.ok(warehouseDTO);
    }

    @GetMapping("/my-list")
    public ResponseEntity<List<WarehouseDTO>> getMyWarehouseList(@AuthenticationPrincipal MemberEntity member) {
        if (member == null) return ResponseEntity.status(401).build();
        return ResponseEntity.ok(warehouseService.getMyWarehouseList(member));
    }

    @PostMapping(value = "/insert", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> insertWarehouse(
        @RequestPart("data") WarehouseDTO warehouseDTO,
        @RequestPart(value = "images", required = false) List<MultipartFile> images,
        @AuthenticationPrincipal MemberEntity member) {
        if (member == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
        if (member.getRole() != Role.ROLE_PROVIDER && member.getRole() != Role.ROLE_ADMIN) {
            return ResponseEntity.status(403).body("창고 등록은 임대인 회원만 가능합니다.");
        }
        try {
            Long warehouseId = warehouseService.insertWarehouse(warehouseDTO, images, member);
            return ResponseEntity.ok().body(warehouseId);
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("등록 실패: " + e.getMessage());
        }
    }

    @PutMapping(value = "/update/{id}", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<?> updateWarehouse(
        @PathVariable("id") Long id,
        @RequestPart("data") WarehouseDTO warehouseDTO,
        @RequestPart(value = "images", required = false) List<MultipartFile> images,
        @AuthenticationPrincipal MemberEntity member) {
        if (member == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
        try {
            warehouseService.updateWarehouse(id, warehouseDTO, images);
            return ResponseEntity.ok().body("수정 완료");
        } catch (Exception e) {
            return ResponseEntity.internalServerError().body("수정 실패: " + e.getMessage());
        }
    }

    @DeleteMapping("/delete/{id}")
    public ResponseEntity<?> deleteWarehouse(
        @PathVariable("id") Long id,
        @AuthenticationPrincipal MemberEntity member) {
        if (member == null) return ResponseEntity.status(401).body("로그인이 필요합니다.");
        try {
            warehouseService.deleteWarehouse(id, member);
            return ResponseEntity.ok().body("삭제 완료");
        } catch (Exception e) {
            log.error("[Warehouse] 삭제 실패", e);
            return ResponseEntity.internalServerError().body("삭제 실패: " + e.getMessage());
        }
    }
}