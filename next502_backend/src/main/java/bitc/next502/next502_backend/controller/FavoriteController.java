package bitc.next502.next502_backend.controller;

import bitc.next502.next502_backend.domain.entity.MemberEntity;
import bitc.next502.next502_backend.domain.entity.WarehouseEntity;
import bitc.next502.next502_backend.service.FavoriteService;
import bitc.next502.next502_backend.service.WarehouseService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map; // ★ Map 임포트 추가됨

@RestController
@RequestMapping("/favorite")
@RequiredArgsConstructor
public class FavoriteController {

    private final FavoriteService favoriteService;
    private final WarehouseService warehouseService;

    @PostMapping("/{whId}")
    public ResponseEntity<String> toggleFavorite(
            @PathVariable("whId") Long whId,
            @AuthenticationPrincipal MemberEntity member) {

        WarehouseEntity warehouse = warehouseService.getWarehouseEntity(whId);
        String result = favoriteService.toggleFavorite(member, warehouse);

        return ResponseEntity.ok(result);
    }


    @GetMapping("/list")
    public ResponseEntity<List<Map<String, Object>>> getMyFavoriteList(
            @AuthenticationPrincipal MemberEntity member) {


        List<Map<String, Object>> favoriteList = favoriteService.getFavoriteList(member);
        return ResponseEntity.ok(favoriteList);
    }
}