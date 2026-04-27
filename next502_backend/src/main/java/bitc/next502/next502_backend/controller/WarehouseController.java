package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.dto.WarehouseDTO;
import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.service.WarehouseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/warehouse") // /product -> /warehouse 로 변경
@RequiredArgsConstructor
public class WarehouseController {

    private final WarehouseService warehouseService; // 변수명 통일

    @GetMapping("/search")
    public ResponseEntity<List<WarehouseEntity>> search(
            @RequestParam(value = "location", required = false) String location,
            @RequestParam(value = "size", required = false) String size, // operation/type -> size (Rank)
            @RequestParam(value = "name", required = false) String name) {

        // 서비스의 바뀐 메서드명 searchWarehouses 호출
        return ResponseEntity.ok(warehouseService.searchWarehouses(location, size, name));
    }

    @PostMapping("/insert")
    public ResponseEntity<String> insertWarehouse(
            @RequestBody WarehouseDTO warehouseDTO,
            @AuthenticationPrincipal MemberEntity member) {

        warehouseService.insertWarehouse(warehouseDTO, member);
        return ResponseEntity.ok("창고 등록이 완료되었습니다.");
    }
}
